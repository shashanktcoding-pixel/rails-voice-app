import { type NextRequest, NextResponse } from "next/server"

const RAILS_API_URL = process.env.NEXT_PUBLIC_RAILS_API_URL ||
                      process.env.RAILS_API_URL ||
                      "http://localhost:3000"

export async function GET(req: NextRequest) {
  try {
    const authToken = req.headers.get('Authorization')?.split(' ')[1]

    if (!authToken) {
      return NextResponse.json({ error: "Unauthorized" }, { status: 401 })
    }

    const response = await fetch(`${RAILS_API_URL}/voices`, {
      headers: {
        'Authorization': `Bearer ${authToken}`
      }
    })

    if (!response.ok) {
      throw new Error(`Failed to fetch voices: ${response.statusText}`)
    }

    const voices = await response.json()
    return NextResponse.json(voices)
  } catch (error) {
    console.error("[voices] Error:", error)
    return NextResponse.json(
      {
        error: `Failed to fetch voices: ${error instanceof Error ? error.message : "Unknown error"}`,
      },
      { status: 500 },
    )
  }
}
