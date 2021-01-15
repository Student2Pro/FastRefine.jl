using FastRefine
using Documenter

makedocs(;
    modules=[FastRefine],
    authors="Alex",
    repo="https://github.com/Student2Pro/FastRefine.jl/blob/{commit}{path}#L{line}",
    sitename="FastRefine.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://Student2Pro.github.io/FastRefine.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/Student2Pro/FastRefine.jl",
)
