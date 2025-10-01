using DataFrames
using XLSX
using UnPack

cd(expanduser("~/code/PRGS/PRGS-Intro-to-ML-2024/"))

function process_repo(s::String)
    s = replace(s, ".git" => "")
    s_split = split(s, '/')
    return (user = s_split[end - 1], repo = s_split[end])
end

function get_file_download(user, repo, path)
    url = "https://raw.githubusercontent.com/$user/$repo/main/$path"
end

function get_ssh_clone(user, repo)
    return "git@github.com:$user/$repo.git"
end

function get_file_download(repo_url::String, n::Int)
    @unpack user, repo = process_repo(repo_url)
    path = "homework/HW_$(string(n, pad = 2)).html"
    get_file_download(user, repo, path)
end

function get_df()
    xl_path = "/Users/ghassler/Library/CloudStorage/OneDrive-SharedLibraries-RANDCorporation/560 Introduction to Machine Learning (AY 2024-25 Fall Quarter) - General/Miscellaneous/GitHub Repos.xlsx"
    df = XLSX.readtable(xl_path, "Sheet1") |> DataFrame
    df
end

function clone_or_pull_all(dir::String)
    df = get_df()

    original_dir = pwd()
    for i in 1:nrow(df)
        @show pwd()
        @show dir
        cd(dir)
        try
            @unpack user, repo = process_repo(df[i, 3])
            nm = df[i, "Preferred Name"]
            if isdir(nm)
                cd(nm)
                cmd = `git pull`
                run(cmd)
                cd("..")
            else
                cmd = `git clone $(get_ssh_clone(user, repo)) $nm`
                run(cmd)
            end
            # cmd = `git clone $(get_ssh_clone(user, repo)) $nm`
            # run(cmd)
        catch
            println("bad github URL or didn't provide GitHub URL")
            cd(original_dir)
        end
    end
    cd(original_dir)
end

function pull_all(dir::String)
    df = get_df()

    original_dir = pwd()
    cd(dir)
    for i in 1:nrow(df)
        nm = df[i, "Preferred Name"]
        try
            @unpack user, repo = process_repo(df[i, 3])
            cd(nm)
            cmd = `git pull`
            run(cmd)
            cd("..")
        catch
            println("$nm: bad github URL or didn't provide GitHub URL")
        end
    end
    cd(original_dir)
end


function copy_all_to_dir(source_dir::String, dest_dir::String, n::Int)
    df = get_df()

    for i in 1:nrow(df)
        nm = df[i, "Preferred Name"]

        try
            @unpack user, repo = process_repo(df[i, 3])
            source_path = joinpath(source_dir, nm, "homework", "HW_$(string(n, pad = 2)).html")
            dest_path = joinpath(dest_dir, "HW_$(string(n, pad = 2))_$(replace(nm, " " => "_")).html")
            cp(source_path, dest_path, force = true)
        catch
            println("Student $i: couldn't copy file")
        end
    end
end

# function download_hw(n::Int)
#     xl_path = "/Users/ghassler/Library/CloudStorage/OneDrive-SharedLibraries-RANDCorporation/560 Introduction to Machine Learning (AY 2024-25 Fall Quarter) - General/Miscellaneous/GitHub Repos.xlsx"
#     df = XLSX.readtable(xl_path, "Sheet1") |> DataFrame
#     repos = df[:, 3]
#     names = df[:, 1]
#     df[!, :result] .= ""
#     for i in 1:nrow(df)
#         download_url = ""
#         try
#             download_url = get_file_download(repos[i], n)
#         catch
#             df[i, :result] = "poorly formatted excel entry"
#             continue
#         end

#         file_path = "graded_homework/HW_" * (string(n, pad = 2)) * "_" * join.(split.(names[i]), '_') .* ".html"

#         try
#             cmd = `curl -o $file_path $download_url`
#             run(cmd)
#         catch
#             df[i, :result] = "bad github URL or didn't provide GitHub URL"
#             continue
#         end

#         file_text = read(file_path, String)
#         if file_text == "404: Not Found"
#             df[i, :result] = "can't find file on GitHub"
#             rm(file_path)
#             continue
#         end
#         df[i, :result] = "successfully submitted"
#     end
#     df
# end

# download_hw(3)


cloned_dir = "../cloned_repos"
clone_or_pull_all(cloned_dir)



# pull_all(cloned_dir)
for i in 2:6
    copy_all_to_dir(cloned_dir, "graded_homework", i)
end
# copy_all_to_dir(cloned_dir, "graded_homework", 4)
