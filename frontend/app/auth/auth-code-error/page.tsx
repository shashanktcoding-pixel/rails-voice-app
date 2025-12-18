import Link from 'next/link'

export default function AuthErrorPage() {
    return (
        <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-gray-50 to-gray-100 dark:from-gray-900 dark:to-gray-800 p-4">
            <div className="w-full max-w-md text-center">
                <div className="bg-white dark:bg-gray-800 rounded-2xl shadow-xl p-8">
                    <h1 className="text-3xl font-bold text-red-600 dark:text-red-400 mb-4">
                        Authentication Error
                    </h1>
                    <p className="text-gray-600 dark:text-gray-400 mb-8">
                        There was a problem authenticating your account. Please try again.
                    </p>
                    <Link href="/login">
                        <a className="w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold py-3 rounded-lg transition-colors duration-200">
                            Back to Login
                        </a>
                    </p>
                </div>
            </div>
        </div>
    )
}
