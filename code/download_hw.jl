using DataFrames
using XLSX
using UnPack

function process_repo(s::String)
    s = replace(s, ".git" => "")
    s_split = split(s, '/')
    return (user = s_split[end - 1], repo = s_split[end])
end

function get_file_download(user, repo, path)
    url = "https://raw.githubusercontent.com/$user/$repo/main/$path"
end

function get_file_download(repo_url::String, n::Int)
    @unpack user, repo = process_repo(repo_url)
    path = "homework/HW_$(string(n, pad = 2)).html"
    get_file_download(user, repo, path)
end


function download_hw(n::Int)
    xl_path = "/Users/ghassler/Library/CloudStorage/OneDrive-SharedLibraries-RANDCorporation/560 Introduction to Machine Learning (AY 2024-25 Fall Quarter) - General/Miscellaneous/GitHub Repos.xlsx"
    df = XLSX.readtable(xl_path, "Sheet1") |> DataFrame
    repos = df[:, 3]
    names = df[:, 1]
    df[!, :result] .= ""
    for i in 1:nrow(df)
        download_url = ""
        try
            download_url = get_file_download(repos[i], n)
        catch
            df[i, :result] = "poorly formatted excel entry"
            continue
        end

        file_path = "graded_homework/HW_" * (string(n, pad = 2)) * "_" * join.(split.(names[i]), '_') .* ".html"

        try
            cmd = `curl -o $file_path $download_url`
            run(cmd)
        catch
            df[i, :result] = "bad github URL or didn't provide GitHub URL"
            continue
        end

        file_text = read(file_path, String)
        if file_text == "404: Not Found"
            df[i, :result] = "can't find file on GitHub"
            rm(file_path)
            continue
        end
        df[i, :result] = "successfully submitted"
    end
    df
end

download_hw(2)

