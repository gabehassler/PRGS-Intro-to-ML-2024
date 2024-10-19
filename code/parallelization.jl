using LinearAlgebra

function rdet(n::Int)
    X = randn(n, n)
    X = X' * X
    logdet(X)
end

rdet(10)

# single threaded

iterations = 10
ns = repeat([100], 20)

t1 = time()
mean_dets = zeros(length(ns)) 
for i = 1:length(ns)
    s = 0
    for j = 1:iterations
        s += rdet(ns[i])
    end

    mean_dets[i] = s / length(ns)
end
t2 = time()

println("Single thread: $(t2 - t1) seconds")

@show Threads.nthreads() # number of threads

t3 = time()

Threads.@threads for i = 1:length(ns)
    @show iterations
    s = 0
    for j = 1:iterations
        s += rdet(ns[i])
    end

    mean_dets[i] = s / length(ns)
end
t4 = time()

println("Parallelized: $(t4 - t3) seconds")