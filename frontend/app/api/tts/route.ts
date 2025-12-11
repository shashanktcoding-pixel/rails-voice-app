import { type NextRequest, NextResponse } from "next/server"

const RAILS_API_URL = process.env.RAILS_API_URL || "http://localhost:3000"
const MAX_POLL_ATTEMPTS = 30
const POLL_INTERVAL_MS = 1000

async function pollForAudio(jobId: number): Promise<string> {
  for (let attempt = 0; attempt < MAX_POLL_ATTEMPTS; attempt++) {
    const statusResponse = await fetch(`${RAILS_API_URL}/voice_status/${jobId}`)

    if (!statusResponse.ok) {
      throw new Error(`Status check failed: ${statusResponse.statusText}`)
    }

    const statusData = await statusResponse.json()
    console.log(`[v0] Poll attempt ${attempt + 1}/${MAX_POLL_ATTEMPTS}:`, statusData.status)

    if (statusData.status === "completed") {
      return statusData.audio_url
    } else if (statusData.status === "failed") {
      throw new Error(statusData.error || "Voice generation failed")
    }

    // Wait before next poll
    await new Promise(resolve => setTimeout(resolve, POLL_INTERVAL_MS))
  }

  throw new Error("Timeout waiting for voice generation")
}

export async function POST(req: NextRequest) {
  try {
    const { text } = await req.json()

    if (!text) {
      return NextResponse.json({ error: "Text is required" }, { status: 400 })
    }

    console.log("[v0] Generating voice for text:", text)

    // Step 1: Create voice generation job
    const createResponse = await fetch(`${RAILS_API_URL}/generate_voice`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ text }),
    })

    if (!createResponse.ok) {
      const errorText = await createResponse.text()
      console.error("[v0] Failed to create job:", errorText)
      return NextResponse.json(
        { error: `Failed to create voice job: ${createResponse.statusText}` },
        { status: createResponse.status },
      )
    }

    const createData = await createResponse.json()
    console.log("[v0] Job created with ID:", createData.id)

    // Step 2: Poll until audio is ready
    const audioUrl = await pollForAudio(createData.id)
    console.log("[v0] Audio ready at:", audioUrl)

    // Step 3: Fetch the audio file
    const audioResponse = await fetch(`${RAILS_API_URL}${audioUrl}`)

    if (!audioResponse.ok) {
      throw new Error("Failed to fetch audio file")
    }

    const audioBlob = await audioResponse.blob()
    console.log("[v0] Audio blob size:", audioBlob.size)

    return new NextResponse(audioBlob, {
      headers: {
        "Content-Type": "audio/mpeg",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type",
      },
    })
  } catch (error) {
    console.error("[v0] TTS Error:", error)
    return NextResponse.json(
      {
        error: `Failed to generate speech: ${error instanceof Error ? error.message : "Unknown error"}`,
      },
      { status: 500 },
    )
  }
}

export async function OPTIONS(req: NextRequest) {
  return new NextResponse(null, {
    headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "POST, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type",
    },
  })
}
