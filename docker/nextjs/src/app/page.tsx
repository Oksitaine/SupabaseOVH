

export default function Home() {
  return (
    <div className="grid grid-rows-[20px_1fr_20px] items-center justify-items-center min-h-screen p-8 pb-20 gap-16 sm:p-20 font-[family-name:var(--font-geist-sans)]">
      <main className="flex flex-col  gap-8 row-start-2 items-center sm:items-start">
        <ol className="list-inside gap-4 flex flex-col items-center list-decimal text-sm text-center font-[family-name:var(--font-geist-mono)]">
          <p className="mb-2 text-lg font-bold text-center">
            You will say what is your favorite anime.
          </p>
          <p className="mb-2">Click for the result.</p>
          <div className="flex gap-4 items-center flex-col sm:flex-row">
            <a
              className="rounded-full border border-solid border-black/[.08] dark:border-white/[.145] transition-colors flex items-center justify-center hover:bg-[#f2f2f2] dark:hover:bg-[#1a1a1a] hover:border-transparent text-sm sm:text-base h-10 sm:h-12 px-4 sm:px-5 sm:min-w-44"
              href="https://media2.giphy.com/media/v1.Y2lkPTc5MGI3NjExbmNrOXZ3eDJyNjEyeDFvazU1YTFmYnpvcTBkOXVqM3ByYTI0aWhwaCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/fTn01fiFdTd5pL60ln/giphy.gif"
              target="_blank"
              rel="noopener noreferrer"
            >
              Demon slayer
            </a>
            ou
            <a
              className="rounded-full border border-solid border-black/[.08] dark:border-white/[.145] transition-colors flex items-center justify-center hover:bg-[#f2f2f2] dark:hover:bg-[#1a1a1a] hover:border-transparent text-sm sm:text-base h-10 sm:h-12 px-4 sm:px-5 sm:min-w-44"
              href="https://media2.giphy.com/media/v1.Y2lkPTc5MGI3NjExbmNrOXZ3eDJyNjEyeDFvazU1YTFmYnpvcTBkOXVqM3ByYTI0aWhwaCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/fTn01fiFdTd5pL60ln/giphy.gif"
              target="_blank"
              rel="noopener noreferrer"
            >
              Kimetsu no yaiba
            </a>
          </div>
        </ol>
      </main>
    </div>
  );
}
