from z3 import *

for s in ('a', 'b', 'c', 'A', 'B', 'C', 'P', 'Q', 'R'):
    #initialise the variables
    exec("x_{n} = Real('x_{n}')".format(n = s))
    exec("y_{n} = Real('y_{n}')".format(n = s))

    #create the point
    exec("{v} = (x_{n}, y_{n})".format(v = s, n = s))

u, v, U, V, dummy = Reals('u v U V dummy')

a, b, c = (1, 0), (1+u, 0), (1+u+v, 0)
A, B, C = A, (x_A*(1+U), y_A*(1+U)), (x_A*(1+U+V), y_A*(1+U+V))

def are_collinear(p_1, p_2, p_3):
    #the condition for collinearity
    #(y_2 - y_1)*(x_3 - x_1) == (y_3 - y_1)*(x_3 - x_1)
    return ( (p_2[1] - p_1[1])*(p_3[0] - p_1[0]) == (p_3[1] - p_1[1])*(p_2[0] - p_1[0]) )

def all_distinct(pts):
    #checks whether all points in the list `pts` are distinct
    return And([Or(Not(p[0] == q[0]), Not(p[1] == q[1])) for (i, p) in enumerate(pts) for (j, q) in enumerate(pts) if j < i])

def parallel(p_1, p_2, q_1, q_2):
    #checks whether the line passing through p_1 and p_2 is parallel to 
    # the line passing through q_1 and q_2
    return (p_2[1] - p_1[1])*(q_2[0] - q_1[0]) == (p_2[0] - p_1[0])*(q_2[1] - q_1[1])

conditions = And([u > 0, v > 0, U > 0, V > 0, all_distinct([a, b, c]), all_distinct([A, B, C]), Not(parallel(a, b, A, B)), dummy == 1**2])

pappus_theorem = Implies(And([are_collinear(p, q, r) for (p, q, r) in (
    (a, b, c), (A, B, C),
    (A, b, P), (B, a, P),
    (B, c, Q), (C, b, Q),
    (C, a, R), (A, c, R)
)] + [conditions]
), are_collinear(P, Q, R))

solve(Not(pappus_theorem))