import sys
import math
from scipy.stats import hmean

def calInteractionAngle(v1,v2):
	return math.atan(v1/v2)*(180/math.pi)


def generateInteractionFeatures(sisVec):

	newFeatVec = []
	for i in range(len(sisVec)):
		for j in range(len(sisVec)):
			if i >= j: continue

			v1, v2 = sisVec[i], sisVec[j]
			feat1 = v1*v2
			feat2 = calInteractionAngle(v1,v2)
			feat3 = hmean([v1,v2])
			newFeatVec.extend([feat1,feat2,feat3])

	return newFeatVec


# The input matrix should have 15 SIS values and 1 fatality label at the right side of the matrix
# In the output matrix file, the newly generated 315 features will be added.
file = sys.argv[1] # input matrix file

fw = open("[your outfile matrix hame here]",'w')
fr = open(file,'r')


line = fr.readline()
m = line.rstrip().split("\t")
fw.write(m[0])
for v in m[1:-1]: fw.write("\t" + v)

for i in range(15):
	for j in range(15):
		if i >= j: continue
		label = str(i+1)+"-"+str(j+1)
		fw.write("\t"+label+"_multiply"+"\t"+label+"_atan"+"\t"+label+"_hmean")
fw.write("\t"+m[-1]+"\n")


for line in fr:
	m = line.rstrip().split("\t")
	sisVec = m[15:-1]
	for i in range(len(sisVec)): sisVec[i] = float(sisVec[i])

	newFeatVec = generateInteractionFeatures(sisVec)
	newVec = m[:-1] + newFeatVec + [m[-1]]
	fw.write(newVec[0])
	for v in newVec[1:]: fw.write("\t" + str(v))
	fw.write("\n")

fr.close()
fw.close()
