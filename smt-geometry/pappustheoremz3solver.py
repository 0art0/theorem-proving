# %%
from z3 import *

#initialising all the points

# `a b c` are collinear
# `A B C` are collinear

# `P Q R` are the points of intersection of the pairs of lines (Ab, Ba), (Bc, Cb), (Ca, Ac) respectively
# In other words, P is a point that lies on the lines Ab and Ba, and likewise with the other two points

for (i, s) in enumerate(('a', 'b', 'c', 'A', 'B', 'C', 'P', 'Q', 'R')):
    #initialise the variables
    exec("x_{j} = Real('x_{j}')".format(j = i))
    exec("y_{j} = Real('y_{j}')".format(j = i))

    #create the point
    exec("{v} = (x_{j}, y_{j})".format(v = s, j = i))

dummy = Real('dummy')

# %%
def are_collinear(p_1, p_2, p_3):
    #the condition for collinearity
    #(y_2 - y_1)*(x_3 - x_1) == (y_3 - y_1)*(x_3 - x_1)
    return ( (p_2[1] - p_1[1])*(p_3[0] - p_1[0]) == (p_3[1] - p_1[1])*(p_2[0] - p_1[0]) )

def all_distinct(pts):
    #checks whether all points in the list `pts` are distinct
    return [Or(Not(p[0] == q[0]), Not(p[1] == q[1])) for (i, p) in enumerate(pts) for (j, q) in enumerate(pts) if j < i]

def parallel(p_1, p_2, q_1, q_2):
    #checks whether the line passing through p_1 and p_2 is parallel to 
    # the line passing through q_1 and q_2
    return (p_2[1] - p_1[1])*(q_2[0] - q_1[0]) == (p_2[0] - p_1[0])*(q_2[1] - q_1[1])
# %%
#this is a formulation of the second statement here - https://en.wikipedia.org/wiki/Pappus's_hexagon_theorem#Other_statements_of_the_theorem


#there were issues when the lines were parallel, hence the extra condition `Not(parallel(A, B, a, b))`
#to prove the theorem in full generality, one can independently prove the case where the two lines are parallel (this should be simpler than the general case)

pappus_theorem = Implies(And([are_collinear(p, q, r) for (p, q, r) in (
    (a, b, c), (A, B, C),
    (A, b, P), (B, a, P),
    (B, c, Q), (C, b, Q),
    (C, a, R), (A, c, R)
)] + [Not(parallel(A, B, a, b)), dummy**2 == dummy**2]
), are_collinear(P, Q, R))
# %%
soln = solve(Not(pappus_theorem))
