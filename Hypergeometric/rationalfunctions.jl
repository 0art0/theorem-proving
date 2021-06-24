include("polynomials.jl")

struct RationalFunction{T, V} <: SpecialFunction where {T <: Number, V <: Indeterminate}
    num::Polynomial{T, V}
    den::Polynomial{T, V}

    #function RationalFunction(p::Polynomial{T}, q::Polynomial{T}) where {T <: Number}
        #let d = GCD(p, q; bezout = false)
        #    isone(d) ? new{T}(p, q) : new{T}(p ÷ d, q ÷ d)
        #end
    #end
end

import Base: convert, promote, show

convert(::Type{RationalFunction{T, V}}, x::Number) where {T <: Number, V <: Indeterminate} = RationalFunction{T, V}(Polynomial(convert(T, x), V), one(Polynomial{T}))
convert(::Type{RationalFunction{T, V}}, r::RationalFunction{S, W}) where {T <: Number, S <: Number, V <: Indeterminate, W <: Indeterminate} = RationalFunction{T, V}(convert(Polynomial{T, V}, r.num), convert(Polynomial{T, V}, r.den))

promote_rule(::Type{RationalFunction{T, V}}, ::Type{S}) where {T <: Number, S <: Number, V <: Indeterminate} = RationalFunction{promote_type(T, S), V} 

import Base: +, -, *, //, inv, zero, one

//(p::Polynomial{T, V}, q::Polynomial{T, V}) where {T <: Number, V <: Indeterminate} = RationalFunction{T, V}(p, q)

+(r::RationalFunction{T, V}, s::RationalFunction{T, V}) where {T <: Number, V <: Indeterminate} = RationalFunction{T, V}(r.num * s.den + s.num * r.den, r.den * r.den)
*(r::RationalFunction{T, V}, s::RationalFunction{T, V}) where {T <: Number, V <: Indeterminate} = RationalFunction{T, V}(r.num * s.num, r.den * s.den)
-(r::RationalFunction{T, V}, s::RationalFunction{T, V}) where {T <: Number, V <: Indeterminate} = r + -1 * s
inv(r::RationalFunction{T, V}) where {T <: Number, V <: Indeterminate} = RationalFunction{T, V}(r.den, r.num)
//(r::RationalFunction{T, V}, s::RationalFunction{T, V}) where {T <: Number, V <: Indeterminate} = r * inv(s)

zero(::Type{RationalFunction{T, V}}) where {T <: Number, V <: Indeterminate} = zero(Polynomial{T, V})//one(Polynomial{T, V})
one(::Type{RationalFunction{T, V}}) where {T <: Number, V <: Indeterminate} = one(Polynomial{T, V})//one(Polynomial{T, V})

(r::RationalFunction)(n::Int) = r.num(n)//r.den(n)

show(io::IO, r::RationalFunction) = print(io, "$(r.num)\n//\n$(r.den)")