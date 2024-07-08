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
    return collect(combinations(collect(1:n),2))
end

function GetPermPair(n)
    return collect(permutations(collect(1:n,2)))
end

function SetGame(n)
    D = 10
    L = 30
    e = rand(n)*30 # Initial ETA for the players

    # pairList = GetPermPair(n)
    # isConflict = Vector{Bool}(undef,length(pairList))
    conflictNum = 0
    seqList = GenSeqSeed(n)
    pairList = GetCombination(n)
    for pairs in pairList
        if abs(e[pairs[1]]-e[pairs[2]]) < D
            conflictNum = conflictNum + 1
        end
    end

    (; D, L, n, e, seqList, conflictNum)
end

# function GetConstraint(x,e,ii,n,seq) # for player ii
#     egoU = x[ii]
#     constraintSet = Vector{Any}(undef,0)
#     for pairs in generateAseq(1,ii,n,2)
#         distance = abs(e[ii]-e[pairs[2]])
#         if distance < D
#             d = D - distance
#             if seq[ii] <= seq[pairs[2]] # ii comes first
#                 constraintSet = vcat(constraintSet, [egoU - x[pairs[2]] - d])
#             else
#                 constraintSet = vcat(constraintSet, [x[pairs[2]] - egoU - d])
#             end
#         end
#     end
#     if isempty(constraintSet)
#         return [0]
#     else
#         return constraintSet
#     end
# end

function GetConstraint(x,e,n,D,seq,ii) # for player ii
    # constraintSet = Vector{Any}(undef,0)
    # pairList = GetCombination(n)
    # for pairs in pairList
    #     distance = abs(e[pairs[1]]-e[pairs[2]])
    #     if distance < D # This pair is in conflict
    #         d = D - distance
    #         if seq[pairs[1]] <= seq[pairs[2]] # 1 is ahead
    #             constraintSet = vcat(constraintSet, [x[pairs[1]] - x[pairs[2]] - d])
    #         else # 2 is ahead
    #             constraintSet = vcat(constraintSet, [x[pairs[2]] - x[pairs[1]] - d])
    #         end
    #     end
    # end
    # return constraintSet[ii]
    constraintSet = Vector{Any}(undef,0)
    pairList = GetCombination(n)
    for pairs in pairList
        if seq[pairs[1]] <= seq[pairs[2]] #1 is ahead
            constraintSet = vcat(constraintSet, [e[pairs[1]] + x[pairs[1]]] - [e[pairs[2]] + x[pairs[2]]] - [D])
        else
            constraintSet = vcat(constraintSet, -[e[pairs[1]] + x[pairs[1]]] + [e[pairs[2]] + x[pairs[2]]] - [D])
        end
    end
    return constraintSet[ii]
end

function EvalJ(u, wm, wp)
end

# Define functions
function generateAseq(i,ai,m,n)
    primeChoice = "1:$m"
    stringUnit = ""
    for j in 1:n
        if j == i
            stringUnit = stringUnit*"$ai"*","
        else
            stringUnit = stringUnit*primeChoice*","
        end
    end
    stringUnit = chop(stringUnit)
    stringSum = "vec(collect(Iterators.product("*stringUnit*")))"
    aSet = eval(Meta.parse(stringSum))
    return aSet
end