include("polynomials.jl")

struct HypergeometricTerm{T, V} <: SpecialFunction where {T <: Number, V <: Indeterminate}
    num::Polynomial{T, V}
    den::Polynomial{T, V}
end

(ht::HypergeometricTerm)(n::Int) = n == 0 ? 1 : ht.num(n)//ht.den(n) * ht(n-1)

struct HypergeometricFunction{T, U, V} <: Function where {T <: Number, U <: Indeterminate, V <: Indeterminate}
    num::Polynomial{Polynomial{T, U}, V}
    den::Polynomial{Polynomial{T, U}, V}

    #this is done to ensure that the summation is finite and ends at the value of `V`
    #HypergeometricFunction(p::Polynomial{Polynomial{T, U}, V}, q::Polynomial{Polynomial{T, U}, V}) where {T <: Number, U <: Indeterminate, V <: Indeterminate} = new{T, U, V}(p * Polynomial([0-𝕩(T, U), one(Polynomial{T, U})], V), q)
end

(hf::HypergeometricFunction)(n::Int) = sum(HypergeometricTerm(hf.num(n), hf.den(n)).(0:n))

Base.show(io::IO, ht::HypergeometricTerm) = print(io, "Hypergeometric term with ratio: $(ht.num) // $(ht.den)")
Base.show(io::IO, hf::HypergeometricFunction) = print(io, "Summation of $(HypergeometricTerm(hf.num, hf.den))")