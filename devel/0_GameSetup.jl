# 2830898829&Courtesy&&&USR&45321&5_1_2021&1000&PATH&GEN&31_12_2025&0_0_0&6000&0_0

using datfm
using BlockArrays
using Combinatorics
using Statistics

function GenSeqSeed(n)
    if n>=10
        println("[Warning] n too big. n! is a dangerous thing.")
    end
    return collect(permutations(collect(1:n)))
end

function GetCombination(n)
    return collect(combinations(n))
end

function SetGame(n, wm, wp)
    D = 10
    L = 30
    e = rand(n)*30 # Initial ETA for the players
    seqList = GenSeqSeed(n)
end

function EvalJ(u)
end

# Define functions
# function generateAseq(i,ai,m,n)
#     primeChoice = "1:$m"
#     stringUnit = ""
#     for j in 1:n
#         if j == i
#             stringUnit = stringUnit*"$ai"*","
#         else
#             stringUnit = stringUnit*primeChoice*","
#         end
#     end
#     stringUnit = chop(stringUnit)
#     stringSum = "vec(collect(Iterators.product("*stringUnit*")))"
#     aSet = eval(Meta.parse(stringSum))
#     return aSet
# end