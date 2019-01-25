import sys
import random
from sets import Set

if __name__ == '__main__':

	file = sys.argv[1]

	SAMPLE_SIZE = 100
	CV = 10
	ONE_FOLD_SIZE = SAMPLE_SIZE/CV

	sampleIdxVec = range(1,SAMPLE_SIZE+1)
	random.shuffle(sampleIdxVec)
	
	tmpVec = []
	
	foldIdx = 0	
	for i in range(1, SAMPLE_SIZE+1, ONE_FOLD_SIZE):
		foldIdx+=1
		if foldIdx > CV: break
		
		startIdx = i
		endIdx = i + ONE_FOLD_SIZE - 1
		
		if foldIdx == CV: endIdx = SAMPLE_SIZE
		
		print foldIdx, startIdx, endIdx, endIdx-startIdx+1
		
		
		testSetIdxVec = sampleIdxVec[startIdx-1:endIdx]
		testSetIdxDict = {}
		for v in testSetIdxVec: testSetIdxDict[v] = True

		
		tmpVec.extend(testSetIdxVec)

		fw1 = open(str(foldIdx) + "_train", "w")
		fw2 = open(str(foldIdx) + "_test", "w")
		
	
		fr = open(file, 'r')
		header = fr.readline()
		fw1.write(header); fw2.write(header)
		sampleIDidx = 0
		for line in fr:
			sampleIDidx+=1
			
			m = line.split("\t")
			
			if sampleIDidx in testSetIdxDict:
				fw2.write(line)
			else:
				fw1.write(line)
				
		fr.close()
		
		fw1.close()
		fw2.close()
	
	print len(tmpVec)
