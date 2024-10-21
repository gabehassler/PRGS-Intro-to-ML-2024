using LinearAlgebra

LinearAlgebra.BLAS.set_num_threads(1)
# const M = randn(100, 100)

function rdet(n::Int)
    X = randn(n, n)
    XtX = X' * X
    logdet(XtX)
end

function fast_rdet(X::Matrix{Float64}, XtX::Matrix{Float64})
    for i in length(X)
        X[i] = randn()
    end
    # fill!(XtX, 0)
    n = size(X, 1)
    # Xt = X'
    LinearAlgebra.mul!(XtX, X', X)
    # for i in 1:n
    #     for j in 1:n
    #         for k in 1:n
    #             XtX[i, j] += X[k, i] * X[k, j]
    #         end
    #     end
    # end
    logdet(XtX)
    # 1.0    
end

function get_mean_fast(ns::Vector{Int}, iterations::Int)
    mean_dets = zeros(length(ns)) 
    Threads.@threads for i = 1:length(ns)
        n = ns[i]
        X = zeros(n, n)
        XtX = zeros(n, n)
        s = 0.0
        for j = 1:iterations
            s += fast_rdet(X, XtX)
        end
        mean_dets[i] = s / iterations
    end
end
            


function get_mean(ns::Vector{Int}, iterations::Int)
    mean_dets = zeros(length(ns)) 
    for i = 1:length(ns)
        s = 0
        for j = 1:iterations
            s += rdet(ns[i])
        end

        mean_dets[i] = s / length(ns)
    end
    mean_dets
end

function get_mean_parallel(ns, iterations)
    esses = zeros(length(ns))
    mean_dets = zeros(length(ns))
    Threads.@threads for i = 1:length(ns)
        for j = 1:iterations
            esses[i] += rdet(ns[i])
        end

        mean_dets[i] = esses[i] / length(ns)
    end
    mean_dets
end

get_mean([1], 1)
md1 = get_mean_parallel([1], 1)
get_mean_fast([1], 1)
rdet(10)

# single threaded

iterations = 100
ns = fill(100, 10)

# t1 = time()
# md1 = get_mean(ns, iterations)
# t2 = time()

@time get_mean(ns, iterations)
@time get_mean_fast(ns, iterations)

error()

println("Single thread: $(t2 - t1) seconds")

@show Threads.nthreads() # number of threads

t3 = time()
md2 = get_mean_parallel(ns, iterations)
t4 = time()

println("Parallelized: $(t4 - t3) seconds")