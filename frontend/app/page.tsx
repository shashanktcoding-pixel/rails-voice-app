"use client"

import { useState, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { Textarea } from "@/components/ui/textarea"
import { Card, CardContent } from "@/components/ui/card"
import { Loader2, Play, Pause, Download, Trash2, Mic, LogOut, ArrowRight, LogIn } from "lucide-react"
import { cn } from "@/lib/utils"
import { useAuth } from "@/contexts/AuthContext"
import Link from "next/link"
import { createClient } from "@/lib/supabase/client"

interface AudioFile {
  id: number
  text: string
  audioUrl: string
  status: string
  created_at: string
  updated_at: string
}

export default function TextToSpeechPage() {
  const { user, loading, signOut } = useAuth()
  const [text, setText] = useState("")
  const [isGenerating, setIsGenerating] = useState(false)
  const [status, setStatus] = useState("")
  const [audioHistory, setAudioHistory] = useState<AudioFile[]>([])
  const [currentPlaying, setCurrentPlaying] = useState<number | null>(null)
  const [loadingHistory, setLoadingHistory] = useState(false)
  const supabase = createClient()

  // Fetch user's voice history
  const fetchHistory = async () => {
    if (!user) return

    setLoadingHistory(true)
    try {
      const { data: { session } } = await supabase.auth.getSession()
      if (!session) return

      const response = await fetch("/api/voices", {
        headers: {
          'Authorization': `Bearer ${session.access_token}`
        }
      })

      if (response.ok) {
        const voices = await response.json()
        const mappedVoices: AudioFile[] = voices
          .filter((v: any) => v.status === 'completed')
          .map((v: any) => ({
            id: v.id,
            text: v.text,
            audioUrl: v.audio_url,
            status: v.status,
            created_at: v.created_at,
            updated_at: v.updated_at
          }))
        setAudioHistory(mappedVoices)
      }
    } catch (error) {
      console.error("Failed to fetch history:", error)
    } finally {
      setLoadingHistory(false)
    }
  }

  useEffect(() => {
    fetchHistory()
  }, [user])

  const handleGenerate = async () => {
    if (!text.trim()) {
      setStatus("Please enter some text")
      return
    }

    setIsGenerating(true)
    setStatus("Generating speech...")

    try {
      const { data: { session } } = await supabase.auth.getSession()
      if (!session) {
        throw new Error("Not authenticated")
      }

      const response = await fetch("/api/tts", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${session.access_token}`
        },
        body: JSON.stringify({ text }),
      })

      if (!response.ok) {
        throw new Error("Failed to generate speech")
      }

      setStatus("Speech generated successfully!")
      setText("")

      // Refetch history to show the new generation
      await fetchHistory()
    } catch (error) {
      setStatus(`Error: ${error instanceof Error ? error.message : "Unknown error"}`)
    } finally {
      setIsGenerating(false)
    }
  }

  const handlePlay = (id: number, audioUrl: string) => {
    if (currentPlaying === id) {
      setCurrentPlaying(null)
      const audio = document.getElementById(`audio-${id}`) as HTMLAudioElement
      audio?.pause()
    }
    else {
      audioHistory.forEach((item) => {
        const audio = document.getElementById(`audio-${item.id}`) as HTMLAudioElement
        audio?.pause()
      })

      setCurrentPlaying(id)
      const audio = document.getElementById(`audio-${id}`) as HTMLAudioElement
      audio?.play()
    }
  }

  const handleDownload = (audioUrl: string, text: string) => {
    const a = document.createElement("a")
    a.href = audioUrl
    a.download = `tts-${text.substring(0, 20).replace(/\s+/g, '-')}-${Date.now()}.mp3`
    a.click()
  }

  const handleDelete = async (id: number) => {
    // For now, just remove from local state
    // TODO: Add delete endpoint to backend
    setAudioHistory(audioHistory.filter((item) => item.id !== id))
    if (currentPlaying === id) {
      setCurrentPlaying(null)
    }
  }

  if (loading) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-background">
        <Loader2 className="h-12 w-12 animate-spin text-primary" />
      </div>
    )
  }

  if (!user) {
    return (
      <main className="min-h-screen bg-background">
        <div className="mx-auto max-w-4xl px-4 py-24 sm:px-6 lg:px-8 text-center flex flex-col items-center">
            <h1 className="mb-6 bg-gradient-to-r from-cyan-400 via-blue-400 to-cyan-300 bg-clip-text text-6xl font-bold tracking-tight text-transparent text-balance sm:text-7xl">
              Welcome to AI Voice Generation
            </h1>
            <p className="mx-auto max-w-2xl text-lg text-muted-foreground leading-relaxed mb-12">
              The most accurate, realistic, and cost-effective text-to-speech APIs. Sign up to start generating high-quality audio.
            </p>
            <div className="flex gap-4">
              <Link href="/signup" passHref>
                <Button size="lg" className="font-medium">
                  Get Started <ArrowRight className="ml-2 h-4 w-4" />
                </Button>
              </Link>
              <Link href="/login" passHref>
                <Button size="lg" variant="outline" className="font-medium">
                  <LogIn className="mr-2 h-4 w-4" /> Log In
                </Button>
              </Link>
            </div>
        </div>
      </main>
    )
  }

  return (
    <main className="min-h-screen bg-background">
      <div className="mx-auto max-w-6xl px-4 py-16 sm:px-6 lg:px-8">
        <div className="flex flex-col sm:flex-row justify-between sm:items-center gap-4 mb-12">
            <div className="text-center sm:text-left">
                <h1 className="bg-gradient-to-r from-cyan-400 via-blue-400 to-cyan-300 bg-clip-text text-5xl font-bold tracking-tight text-transparent sm:text-6xl">
                    Text to Speech
                </h1>
                <p className="mt-2 text-lg text-muted-foreground">
                    Welcome, {user.email}
                </p>
            </div>
            <Button onClick={signOut} variant="outline" className="w-full sm:w-auto">
                <LogOut className="mr-2 h-4 w-4" /> Sign Out
            </Button>
        </div>


        <Card className="mb-12 border-border/50 bg-card/50 backdrop-blur">
          <CardContent className="space-y-6 p-8">
            <div className="space-y-3">
              <label className="flex items-center gap-2 text-sm font-medium text-foreground">
                <Mic className="size-4 text-primary" />
                Enter Your Text
              </label>
              <Textarea
                placeholder="Type or paste your text here..."
                value={text}
                onChange={(e) => setText(e.target.value)}
                className="min-h-40 resize-none border-border/50 bg-background/50 text-base leading-relaxed"
                disabled={isGenerating}
              />
            </div>

            <div className="flex flex-col items-start justify-between gap-4 sm:flex-row sm:items-center">
              <div className="flex-1">
                {status && (
                  <p className={cn("text-sm", status.includes("Error") ? "text-destructive" : "text-primary/80")}>
                    {status}
                  </p>
                )}
              </div>

              <Button
                onClick={handleGenerate}
                disabled={isGenerating || !text.trim()}
                size="lg"
                className="bg-primary font-medium text-primary-foreground hover:bg-primary/90"
              >
                {isGenerating ? (
                  <>
                    <Loader2 className="mr-2 size-4 animate-spin" />
                    Generating...
                  </>
                ) : (
                  "Generate Speech"
                )}
              </Button>
            </div>
          </CardContent>
        </Card>

        <div>
          <h2 className="mb-6 text-2xl font-semibold text-foreground">Audio History</h2>

          {audioHistory.length > 0 ? (
            <div className="space-y-3">
              {audioHistory.map((item) => (
                <Card
                  key={item.id}
                  className="border-border/50 bg-card/50 backdrop-blur transition-colors hover:bg-card/70"
                >
                  <CardContent className="flex items-center gap-4 p-5">
                    <Button
                      variant="outline"
                      size="icon"
                      onClick={() => handlePlay(item.id, item.audioUrl)}
                      className="shrink-0 border-primary/30 bg-primary/10 hover:bg-primary/20 hover:text-primary"
                    >
                      {currentPlaying === item.id ? <Pause className="size-4" /> : <Play className="size-4" />}
                    </Button>

                    <div className="min-w-0 flex-1">
                      <p className="truncate text-sm font-medium text-foreground">{item.text}</p>
                      <p className="text-xs text-muted-foreground">{new Date(item.created_at).toLocaleString()}</p>
                    </div>

                    <audio
                      id={`audio-${item.id}`}
                      src={item.audioUrl}
                      onEnded={() => setCurrentPlaying(null)}
                      className="hidden"
                    />

                    <div className="flex gap-2">
                      <Button
                        variant="ghost"
                        size="icon"
                        onClick={() => handleDownload(item.audioUrl, item.text)}
                        className="hover:bg-primary/10 hover:text-primary"
                      >
                        <Download className="size-4" />
                      </Button>
                      <Button
                        variant="ghost"
                        size="icon"
                        onClick={() => handleDelete(item.id)}
                        className="hover:bg-destructive/10 hover:text-destructive"
                      >
                        <Trash2 className="size-4" />
                      </Button>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          ) : (
            <Card className="border-border/50 bg-card/30 backdrop-blur">
              <CardContent className="py-16 text-center">
                <p className="text-muted-foreground">No audio files yet. Generate your first speech above!</p>
              </CardContent>
            </Card>
          )}
        </div>
      </div>
    </main>
  )
}
