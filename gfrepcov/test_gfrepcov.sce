//This is code for testing gfrepcov

// The matrix below represents the binary polynomial 1 + s + s^2 + s^4
// Implies output vector should be [1 1 1 0 1]
A=[0 1 2 4 ]
B=gfrepcov(A)
disp(B)
// Also try A=[1 2 3 4 4] which is incorrect way of representing binary polynomial
