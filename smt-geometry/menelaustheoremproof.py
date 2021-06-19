# This is a proof of Menelaus' theorem (https://en.wikipedia.org/wiki/Menelaus%27s_theorem) using the z3 solver

# %%
from z3 import *

# %%
# A, B, C are the vertices of the triangle. 
# WLOG, it is assumed to have a base of unit length on the x-axis, with the third point above the x-axis.
A = (x_a, y_a) = Reals('x_a y_a')
B = (x_b, y_b) = Reals('x_b y_b')
C = (x_c, y_c) = Reals('x_c y_c')

# Each of the edges of the triangle can be parameterised by a single variable,
# which is equal to the first vertex at 0 and equal to the second vertex at 1
r, s, t = Reals('r s t')

def cut(l, P, Q):
    #with the line PQ parameterised as described above,
    #this function returns the point obtained when the parameter is equal to `l`
    return (P[0] + l*(Q[0] - P[0]), P[1] + l*(Q[1] - P[1]))

# D, E, F are points on the edges AB, BC, CA respectively
D, E, F = cut(r, A, B), cut(s, B, C), cut(t, C, A)

def are_collinear(p_1, p_2, p_3):
    #the condition for collinearity
    #(y_2 - y_1)*(x_3 - x_1) == (y_3 - y_1)*(x_3 - x_1)
    return ( (p_2[1] - p_1[1])*(p_3[0] - p_1[0]) == (p_3[1] - p_1[1])*(p_2[0] - p_1[0]) )

square = lambda x:  x**2

def d(p, q):
    #returns the square of the Euclidean distance between points p and q
    return square(p[0] - q[0]) + square(p[1] - q[1])

def in_bounds(l):
    #checks whether the parameter is within the range (0, 1)
    #i.e, whether the point corresponding to the parameter value `l` is contained within the corresponding edge or on an extension of it
    return And(0 < l, l < 1)

# for the converse of Menelaus theorem to hold, the number of intersection points lying on the extensions of edges must either be 1 or 3 (https://brilliant.org/wiki/menelaus-theorem/#theorem)
# the following two expressions capture these conditions
# alternatively, one can define "signed" distances to make the theorem more general

one_not_in_bounds = Or([
    And([Not(in_bounds(r)), in_bounds(s), in_bounds(t)]),
    And([in_bounds(r), Not(in_bounds(s)), in_bounds(t)]),
    And([in_bounds(r), in_bounds(s), Not(in_bounds(t))])
])
three_not_in_bounds = And([Not(in_bounds(r)), Not(in_bounds(s)), Not(in_bounds(t))])

# this is the equation that the distances (rather, the squares of the distances) must satisfy
dist_eq = d(A, D) * d(B, E) * d(C, F) == d(D, B) * d(E, C) * d(F, A)

print(dist_eq)
# %%s
#these are the "forward" and "backward" statements of the theorem
menelaus_thm_fwd = Implies(And(Not(are_collinear(A, B, C)), are_collinear(D, E, F)), dist_eq)
menelaus_thm_bwd = Implies(And(Not(are_collinear(A, B, C)), Or(one_not_in_bounds, three_not_in_bounds), dist_eq), are_collinear(D, E, F))
# %%
#proving the theorems by contradiction
solve(Not(menelaus_thm_fwd))
solve(Not(menelaus_thm_bwd))
