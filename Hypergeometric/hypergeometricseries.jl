include("polynomials.jl")

struct HypergeometricTerm{T, V} <: SpecialFunction where {T <: Number, V <: Indeterminate}
    num::Polynomial{T, V}
    den::Polynomial{T, V}
end

(ht::HypergeometricTerm)(n::Int) = n == 0 ? 1 : ht.num(n)//ht.den(n) * ht(n-1)

struct HypergeometricSeries{T, U, V} <: SpecialFunction where {T <: Number, U <: Indeterminate, V <: Indeterminate}
    num::Polynomial{Polynomial{T, U}, V}
    den::Polynomial{Polynomial{T, U}, V}
end

(hf::HypergeometricSeries)(n::Int) = sum(HypergeometricTerm(hf.num(n), hf.den(n)).(0:n))

Base.show(io::IO, ht::HypergeometricTerm) = print(io, "Hypergeometric term with ratio: $(ht.num) // $(ht.den)")
Base.show(io::IO, hf::HypergeometricSeries) = print(io, "Summation of $(HypergeometricTerm(hf.num, hf.den))")

import Base: rand

rand(::Type{Polynomial{Int, V}}) where {V <: Indeterminate} = Polynomial(rand(-2:2, rand(1:2)), V)
rand(::Type{Polynomial{Polynomial{Int, U}, V}}) where {U <: Indeterminate, V <: Indeterminate} = Polynomial([rand(Polynomial{Int, U}) for i ∈ 1:rand(1:2)], V)
rand(::Type{HypergeometricTerm{Int, V}}) where {V <: Indeterminate} = HypergeometricTerm(rand(Polynomial{Int, V}), rand(Polynomial{Int, V}))
rand(::Type{HypergeometricSeries{Int, U, V}}) where {U <: Indeterminate, V <: Indeterminate} = HypergeometricSeries(rand(Polynomial{Polynomial{Int, U}, V}), rand(Polynomial{Polynomial{Int, U}, V}))