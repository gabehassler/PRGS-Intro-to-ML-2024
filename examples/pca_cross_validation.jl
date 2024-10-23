using DataFrames
using CSV
using LinearAlgebra
using RCall
using Statistics


# approximates the data matrix X using the first k principal components
# X must be standardized to have mean 0 and standard deviation 1
function pca_approx(X, k)
    X_svd = svd(X)
    Uk = X_svd.U[:, 1:k]
    Sk = Diagonal(X_svd.S[1:k])
    Vtk = X_svd.Vt[1:k, :]
    return Uk * Sk * Vtk
end

# computes the cross-validated error of approximating X using the first k principal components
# X must be standardized to have mean 0 and standard deviation 1
# folds is a matrix of the same size as X with integers from 1 to n
# typically folds will have the numbers 1:n randomly assigned for each element
function pca_cv_error(X, k, folds)
    fs = unique(folds)

    # get the mean of each column of X
    means = mean(X, dims=1)

    # initialize the vector to store the errors
    errs = zeros(length(fs))

    # loop over the folds
    for i in 1:length(fs)
        f = fs[i]

        # create a copy of X with the values of fold f replaced by the column means
        X_cv = deepcopy(X)

        # for all indices of X where the fold is f, replace the value with the column mean
        for i in 1:size(X, 2)
            for j in 1:size(X, 1)
                if folds[j, i] == f
                    X_cv[j, i] = means[i]
                end
            end
        end

        # approximate X_cv using the first k principal components
        X̂ = pca_approx(X_cv, k)

        # compute the error of the approximation for only the replaced values
        err = 0.0
        for i in 1:size(X, 2)
            for j in 1:size(X, 1)
                if folds[j, i] == f
                    err += (X̂[j, i] - X[j, i])^2
                end
            end
        end
        errs[f] = err
    end

    # return the average error
    return sum(errs) / length(X)
end

# load the data
data = CSV.read("data/processed/nri_svi_merged.csv", DataFrame, missingstring="NA")

# subset and clean the data
vars = ["EP_POV150", "EP_UNEMP", "EP_HBURD", "EP_NOHSDP", "EP_UNINSUR", 
    "EP_AGE65", "EP_AGE17", "EP_DISABL", "EP_SNGPNT", "EP_LIMENG", "EP_MINRTY", 
    "EP_MUNIT", "EP_MOBILE", "EP_CROWD", "EP_NOVEH", "EP_GROUPQ", "EP_NOINT"]
data_svi = data[!, vars]
data_svi = data_svi[completecases(data_svi), :]

# convert the data to a matrix and standardize it
X = Matrix{Float64}(data_svi)
mu = mean(X, dims=1)
sd = std(X, dims=1)

X = (X .- mu) ./ sd

# create a matrix of random folds
n_folds = 20
folds = rand(1:n_folds, size(X, 1), size(X, 2))

# TODO: compute the cross-validated error of approximating X using the first k principal components for k = 1:17
#   you should use the pca_cv_error function
# TODO: what is the optimal number of principal components to use?