import { NextResponse, type NextRequest } from 'next/server'

export async function GET(request: NextRequest) {
  const { searchParams, origin } = new URL(request.url)
  const code = searchParams.get('code')

  // If there's an OAuth code, redirect to the auth callback handler
  if (code) {
    const next = searchParams.get('next') ?? '/'
    return NextResponse.redirect(`${origin}/auth/callback?code=${code}&next=${next}`)
  }

  // No code, return 404 to let page.tsx handle it
  return NextResponse.next()
}
