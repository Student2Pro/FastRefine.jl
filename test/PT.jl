t = Template(;
    user="Student2Pro",
    dir="C:/Users/Cloud Johnson/.julia/dev",
    authors="Alex",
    julia=v"1.5",
    plugins=[
        License(),
        Git(;name="CloudJohnson", email="cbtk_5ifth@qq.com", manifest=true),
        GitHubActions(; x86=true),
        Codecov(),
        Documenter{GitHubActions}(),
        TravisCI(),
    ],
)

#t("PkgName")
