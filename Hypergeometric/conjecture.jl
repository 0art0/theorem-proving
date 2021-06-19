include("polynomials.jl")
include("rationalfunctions.jl")
include("hypergeometricseries.jl")

Base.rand(::Type{Polynomial{Int, V}}) where {V <: Indeterminate} = Polynomial(rand(-2:2, rand(1:2)), V)
Base.rand(::Type{Polynomial{Polynomial{Int, U}, V}}) where {U <: Indeterminate, V <: Indeterminate} = Polynomial([rand(Polynomial{Int, U}) for i ∈ 1:rand(1:2)], V)
Base.rand(::Type{HypergeometricTerm{Int, V}}) where {V <: Indeterminate} = HypergeometricTerm(rand(Polynomial{Int, V}), rand(Polynomial{Int, V}))
Base.rand(::Type{HypergeometricFunction{Int, U, V}}) where {U <: Indeterminate, V <: Indeterminate} = HypergeometricFunction(rand(Polynomial{Polynomial{Int, U}, V}), rand(Polynomial{Polynomial{Int, U}, V}))

matches = 5

dictionary = Dict{NTuple{matches, Rational}, Vector{Function}}()

for _ ∈ 1:50_000
    try
        h = rand() < 0.5 ? rand(HypergeometricFunction{Int, K, N}) : rand(HypergeometricTerm{Int, N})
        values = ntuple(i -> h(i), matches)

        if h.num == (n - (k - 1)*n^0) && h.den == k*n^0
            println("Matched ", h)
        end

        if haskey(dictionary, values) 
            if !any([h.num * g.den == h.den * g.num for g ∈ dictionary[values] if typeof(g) == typeof(h)])
                push!(dictionary[values], h)
            end
        else
            dictionary[values] = Function[h]
        end
    catch error
        #print(error)
    end
end

for (v, f) ∈ dictionary
    if length(f) > 1
        println((v))
    end
end