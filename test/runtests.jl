using Test
using TestExtras
using Random
using SUNRepresentations
using TensorKit
using Combinatorics
using TensorKit
using TensorKit: ProductSector, fusiontensor
using TensorOperations
TensorOperations.disable_cache() # avoids memory overflow during CI?
using TupleTools
using TupleTools: StaticLength
using Base.Iterators: take, product
import LinearAlgebra

const TK = TensorKit

Random.seed!(1234)

smallset(::Type{I}) where {I<:Sector} = take(values(I), 5)
function smallset(::Type{ProductSector{Tuple{I1,I2}}}) where {I1,I2}
    iter = product(smallset(I1), smallset(I2))
    s = collect(i ⊠ j for (i,j) in iter if dim(i)*dim(j) <= 6)
    return length(s) > 6 ? rand(s, 6) : s
end
function smallset(::Type{ProductSector{Tuple{I1,I2,I3}}}) where {I1,I2,I3}
    iter = product(smallset(I1), smallset(I2), smallset(I3))
    s = collect(i ⊠ j ⊠ k for (i,j,k) in iter if dim(i)*dim(j)*dim(k) <= 6)
    return length(s) > 6 ? rand(s, 6) : s
end
function randsector(::Type{I}) where {I<:Sector}
    s = collect(smallset(I))
    a = rand(s)
    while a == one(a) # don't use trivial label
        a = rand(s)
    end
    return a
end
function hasfusiontensor(I::Type{<:Sector})
    try
        fusiontensor(one(I), one(I), one(I))
        return true
    catch e
        if e isa MethodError
            return false
        else
            rethrow(e)
        end
    end
end

# sectorlist = (SUNIrrep{3}, SUNIrrep{4}, SUNIrrep{5}, SUNIrrep{3} ⊠ SUNIrrep{3})
sectorlist = ()

Ti = time()
include("sectors.jl")
include("fusiontrees.jl")
Tf = time()
printstyled("Finished all tests in ",
            string(round((Tf-Ti)/60; sigdigits=3)),
            " minutes."; bold = true, color = Base.info_color())
println()
