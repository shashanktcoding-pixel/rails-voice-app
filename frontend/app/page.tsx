"use client"

import { useState } from "react"
import { Button } from "@/components/ui/button"
import { Textarea } from "@/components/ui/textarea"
import { Card, CardContent } from "@/components/ui/card"
import { Loader2, Play, Pause, Download, Trash2, Mic } from "lucide-react"
import { cn } from "@/lib/utils"

interface AudioFile {
  id: string
  text: string
  audioUrl: string
  timestamp: number
}

export default function TextToSpeechPage() {
  const [text, setText] = useState("")
  const [isGenerating, setIsGenerating] = useState(false)
  const [status, setStatus] = useState("")
  const [audioHistory, setAudioHistory] = useState<AudioFile[]>([])
  const [currentPlaying, setCurrentPlaying] = useState<string | null>(null)

  const handleGenerate = async () => {
    if (!text.trim()) {
      setStatus("Please enter some text")
      return
    }

    setIsGenerating(true)
    setStatus("Generating speech...")

    try {
      const response = await fetch("/api/tts", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ text }),
      })

      if (!response.ok) {
        throw new Error("Failed to generate speech")
      }

      const blob = await response.blob()
      const audioUrl = URL.createObjectURL(blob)

      const newAudio: AudioFile = {
        id: Date.now().toString(),
        text: text.substring(0, 50) + (text.length > 50 ? "..." : ""),
        audioUrl,
        timestamp: Date.now(),
      }

      setAudioHistory([newAudio, ...audioHistory])
      setStatus("Speech generated successfully!")
      setText("")
    } catch (error) {
      setStatus(`Error: ${error instanceof Error ? error.message : "Unknown error"}`)
    } finally {
      setIsGenerating(false)
    }
  }

  const handlePlay = (id: string, audioUrl: string) => {
    if (currentPlaying === id) {
      setCurrentPlaying(null)
      const audio = document.getElementById(`audio-${id}`) as HTMLAudioElement
      audio?.pause()
    } else {
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
    a.download = `tts-${Date.now()}.mp3`
    a.click()
  }

  const handleDelete = (id: string) => {
    setAudioHistory(audioHistory.filter((item) => item.id !== id))
    if (currentPlaying === id) {
      setCurrentPlaying(null)
    }
  }

  return (
    <main className="min-h-screen bg-background">
      <div className="mx-auto max-w-6xl px-4 py-16 sm:px-6 lg:px-8">
        <div className="mb-16 text-center">
          <h1 className="mb-6 bg-gradient-to-r from-cyan-400 via-blue-400 to-cyan-300 bg-clip-text text-6xl font-bold tracking-tight text-transparent text-balance sm:text-7xl">
            Text to Speech
          </h1>
          <p className="mx-auto max-w-2xl text-lg text-muted-foreground leading-relaxed">
            Build with the most accurate, realistic, and cost-effective APIs for text-to-speech. Trusted by developers
            and leading enterprises.
          </p>
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
                      <p className="text-xs text-muted-foreground">{new Date(item.timestamp).toLocaleString()}</p>
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
