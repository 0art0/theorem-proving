using Base: Symbol, Number, String

abstract type Function <: Number end
abstract type Indeterminate end

for v ∈ (:X, :Y, :Z, :K, :N)
    @eval abstract type $v <: Indeterminate end
end

struct Polynomial{T <: Number, V <: Indeterminate} <: Function
    coefs::Vector{T}
    degree::Int

    function Polynomial(coefs::Union{Vector{T}, Tuple{Vararg{T}}}, v::Type{V}) where {T <: Number, V <: Indeterminate}
        ##trimming the polynomial
        while length(coefs) > 0 && coefs[end] == zero(T)
            coefs = coefs[begin:end-1]
        end

        new{T, v}(coefs, length(coefs) - 1)
    end
end

import Base: getindex, convert, promote_rule, promote_type, firstindex, lastindex, zero, one

getindex(p::Polynomial{T, V}, i::Int) where {T <: Number, V <: Indeterminate} = (0 ≤ i ≤ p.degree) ? p.coefs[i+1] : zero(T)

convert(::Type{Polynomial{T, V}}, x::Number) where {T <: Number, V <: Indeterminate} = Polynomial(T[convert(T, x)], V)
convert(::Type{Polynomial{T, V}}, p::Polynomial{S, W}) where {T <: Number, S <: Number, V <: Indeterminate, W <: Indeterminate} = Polynomial(convert.(T, p.coefs), V)

promote_rule(::Type{Polynomial{T, V}}, ::Type{S}) where {T <: Number, S <: Number, V <: Indeterminate} = Polynomial{promote_type(T, S), V}

firstindex(p::Polynomial) = 0
lastindex(p::Polynomial) = p.degree

zero(::Type{Polynomial{T, V}}) where {T <: Number, V <: Indeterminate} = Polynomial([zero(T)], V)
zero(::Type{Polynomial}) = Polynomial([0])

one(::Type{Polynomial{T, V}}) where {T <: Number, V <: Indeterminate} = Polynomial([one(T)], V)
one(::Type{Polynomial})::Polynomial = Polynomial([1])

Base.show(io::IO, p::Polynomial{T, V}) where {T <: Number, V <: Indeterminate} = print(io, join(reverse(vcat(["$(p[0])"], iszero(p[1]) ? String[] : ["$(p[1])$(V)"] , ["$(p[i])$(V)^$i" for i ∈ 2:p.degree if p[i] != zero(T)])), " + "))
Base.show(io::IO, p::Polynomial{Polynomial{T, U}, V}) where {T <: Number, U <: Indeterminate, V <: Indeterminate} = print(io, join(reverse(vcat(["($(p[0]))"],  (iszero(p[1]) ? String[] : ["($(p[1])$(V))"]) , ["($(p[i]))$(V)^$i" for i ∈ 2:p.degree if p[i] != zero(T)])), " + "))

(p::Polynomial)(x) = evalpoly(x, p.coefs) 

x = Polynomial([zero(Int), one(Int)], X)
y = Polynomial([zero(Float64), one(Float64)], Y)
z = Polynomial([zero(Complex), one(Complex)], Z)
k = Polynomial([zero(Int), one(Int)], K)
n = Polynomial([zero(Polynomial{Int, K}), one(Polynomial{Int, K})], N)
𝕩(::Type{T}, ::Type{V}) where {T <: Number, V <: Indeterminate} = Polynomial(T[zero(T), one(T)], V)

import Base: +, -, *, ÷, %, mod

+(p::Polynomial{T, V}, q::Polynomial{T, V}) where {T <: Number, V <: Indeterminate} = Polynomial([p[i] + q[i] for i ∈ 0:max(p.degree, q.degree)+1], V)
-(p::Polynomial{T, V}, q::Polynomial{T, V}) where {T <: Number, V <: Indeterminate} = Polynomial([p[i] - q[i] for i ∈ 0:max(p.degree, q.degree)+1], V)
*(p::Polynomial{T, V}, q::Polynomial{T, V}) where {T <: Number, V <: Indeterminate} = Polynomial([sum([p[j] * q[i - j] for j ∈ 0:i]) for i ∈ 0:(p.degree + q.degree)], V) 

*(p::Polynomial{T, W}, q::Polynomial{Polynomial{T, W}, V}) where {T <: Number, V <: Indeterminate, W <: Indeterminate} = Polynomial(Polynomial{T, W}[p], V) * q
*(q::Polynomial{Polynomial{T, W}, V}, p::Polynomial{T, W}) where {T <: Number, V <: Indeterminate, W <: Indeterminate} = q * Polynomial(Polynomial{T, W}[p], V)


function ÷(p::Polynomial{T, V}, q::Polynomial{T, V}) where {T <: Number, V <: Indeterminate}
    let (δ, r, 𝚡) = (p.degree - q.degree, p[end]/q[end], 𝕩(T, V))
        try r = convert(T, r);
        catch; throw("Division is not possible in the polynomial ring over $T.") end
        
        δ < 0 ? zero(Polynomial{T, V}) : r*𝚡^δ + ÷(p - q*r*𝚡^δ, q)
    end
end
%(p::Polynomial{T, V}, q::Polynomial{T, V}) where {T <: Number, V <: Indeterminate} = p - q*(p ÷ q)
mod(p::Polynomial{T, V}, q::Polynomial{T, V}) where {T <: Number, V <: Indeterminate} = p % q

import Base: <, >, ==

<(p::Polynomial, q::Polynomial)::Bool = p.degree < q.degree
>(p::Polynomial, q::Polynomial)::Bool = p.degree > q.degree
==(p::Polynomial, q::Polynomial)::Bool = (p.degree == q.degree) && (p.coefs == q.coefs)

ν(p::Polynomial) = iszero(p) ? Inf : (findfirst(!iszero, p.coefs) - 1)

function GCD(p::T, q::T; bezout = true) where {T <: Number}
    a, b = ( p >= q ? (p, q) : (q, p) ) .|> copy
    bez, out = [1, 0], [0, 1]

    while !iszero(b) 
        q, r = divrem(a, b)
        
        bez, out = out, bez - q.*out 
	a, b = b, r
    end

    bezout ? (a, bez) : a
end
