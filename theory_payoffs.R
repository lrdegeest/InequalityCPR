# about -------------------------------------------------------------------
# this file produces the theoretical payoffs in Table 1 of the manuscript
# author: @lrdegeest


# payoff function ---------------------------------------------------------
pi <- function(e,x,y=0,low=0,high=0) {
  private = e - x
  surplus = x + y + low + high
  surplus_value = 6*surplus - 0.025*surplus^2
  surplus_share = x/surplus
  payoff = private + surplus_share*surplus_value
  return(payoff)
}


# homogenous endowments ---------------------------------------------------

# social optimum
pi(e=50,x=25,y=3*25)
# nash
pi(e=50,x=40,y=3*40)


# heterogenous endowments -------------------------------------------------

# Nash
## high
pi(e=60,x=40,low=2*40,high=1*40)
## low
pi(e=40,x=40,low=1*40,high=2*40)

# SOCIAL OPTIMUM: EQUAL EXTRACTIONS
# high
pi(e=60,x=25,low=2*25,high=1*25)
# low
pi(e=40,x=25,low=1*25,high=2*25)

# SOCIAL OPTIMUM: EQUAL PAYOFFS
h = 21 # high extraction
l = 29 # low extraction
pi(e=60,x=h,low=2*l,high=1*h) # high payoffs
pi(e=40,x=l,low=1*l,high=2*h) # low payoffs

# SOCIAL OPTIMUM: EQUAL PROPORTIONS
h = 30 # high extraction
l = 20 # low extraction
pi(e=60,x=h,low=2*l,high=1*h) # high payoffs
pi(e=40,x=l,low=1*l,high=2*h) # low payoffs