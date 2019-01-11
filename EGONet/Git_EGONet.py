import numpy as np
import tensorflow as tf
import math

#You can change those parameter for your model
learning_rate = tf.Variable(0.002)
training_epochs = 200
display_step = 10
DROPOUT_CONV = 0.8
DROPOUT_HIDDEN = 0.5


def init_weights(shape):
    return tf.Variable(tf.random_normal(shape, stddev=0.01))



def define_DBN():
    #X for input, training data matrix
	X = tf.placeholder(tf.float32, [None, 20, 18, 1], name="X")

    #X for data lables, such as lethal, non-lethal attempter
	Y = tf.placeholder(tf.float32, [None, 1], name="Y")
	p_keep_conv = tf.placeholder(tf.float32)
	p_keep_hidden = tf.placeholder(tf.float32)

	w1 = init_weights([1, 3, 1, 32])       # 4x4x1 conv, 32 outputs
	w2 = init_weights([1, 1, 32, 64])     # 3x3x32 conv, 64 outputs
	w3 = init_weights([3, 1, 64, 128])     # 3x3x32 conv, 64 outputs

	w4 = init_weights([128 * 10 * 6, 768]) # FC 64 * 5 * 31 inputs(9920), 992 outputs
	w_o= init_weights([768, 1])         # FC 614 inputs, 1 outputs (labels)

	w1_summ = tf.summary.histogram("w1", w1)
	w2_summ = tf.summary.histogram("w2", w2)
	w4_summ = tf.summary.histogram("w4", w4)
	w_o_summ = tf.summary.histogram("w_o", w_o)

	l1 = tf.nn.relu6(tf.nn.conv2d(X, w1,                       # l1a shape=(?, 20, 18, 32)
			    strides=[1, 1, 3, 1], padding='SAME'))
#	l1 = tf.nn.max_pool(l1, ksize=[1, 1, 3, 1],              # l1 shape=(?, 20, 6, 32)
#			    strides=[1, 1, 3, 1], padding='SAME')
	l1 = tf.nn.dropout(l1, p_keep_conv)


	l2 = tf.nn.relu6(tf.nn.conv2d(l1, w2,                     # l2a shape=(?, 20, 6, 64)
			    strides=[1, 1, 1, 1], padding='SAME'))
#	l2 = tf.nn.max_pool(l2, ksize=[1, 2, 2, 1],              # l2 shape=(?, 10, 3, 64)
#			    strides=[1, 2, 2, 1], padding='SAME')
	l2 = tf.nn.dropout(l2, p_keep_conv)


	l3 = tf.nn.relu6(tf.nn.conv2d(l2, w3,                       # l3a shape=(?, 20, 6, 128)
			    strides=[1, 1, 1, 1], padding='SAME'))
	l3 = tf.nn.max_pool(l3, ksize=[1, 2, 1, 1],              # l3 shape=(?, 10, 6, 128)
			    strides=[1, 2, 1, 1], padding='SAME')

	l3 = tf.reshape(l3, [-1, w4.get_shape().as_list()[0]])    # reshape to (?, 7680)
	l3 = tf.nn.dropout(l3, p_keep_conv)

	l4 = tf.nn.relu6(tf.matmul(l3, w4))
	l4 = tf.nn.dropout(l4, p_keep_hidden)

	hypothesis = tf.sigmoid(tf.matmul(l4, w_o))
	hypothesis = tf.clip_by_value(hypothesis,1e-10,0.99999) ###



	with tf.name_scope("cost") as scope:
		cost = -tf.reduce_mean(Y*tf.log(hypothesis) + (1-Y)*tf.log(1-hypothesis))
		cost_summ = tf.summary.scalar("cost", cost)

	with tf.name_scope("train") as scope:
		optimizer = tf.train.AdamOptimizer(learning_rate)
		train = optimizer.minimize(cost)

	init = tf.global_variables_initializer()


	return X, Y, hypothesis, cost, train, init, p_keep_conv, p_keep_hidden



def DBN_learning(iterCV, trainFile, testFile, X, Y, hypothesis, cost, train, init, p_keep_conv, p_keep_hidden):

	xy = np.loadtxt(trainFile, unpack=True, skiprows=1, usecols=range(1,362))
	x_data = xy[0:-1]
	y_data = xy[-1]
	x_data = np.transpose(x_data)
	y_data = np.transpose(y_data)
	x_data = x_data.reshape(-1, 20, 18, 1)
	y_data = y_data.reshape(-1, 1)

	test_xy = np.loadtxt(testFile, unpack=True, skiprows=1, usecols=range(1,362))
	test_x_data = test_xy[0:-1]
	test_y_data = test_xy[-1]

	test_x_data = np.transpose(test_x_data)
	test_y_data = np.transpose(test_y_data)
	test_x_data = test_x_data.reshape(-1, 20, 18, 1)
	test_y_data = test_y_data.reshape(-1, 1)


	fw=open("predictedValuesLog_new"+str(iterCV), 'w') #for prediction results print out into file by k-fold

	with tf.Session() as sess:

		correct_prediction = tf.equal(tf.floor(hypothesis+0.5), Y)
		accuracy = tf.reduce_mean(tf.cast(correct_prediction, "float"))
		accuracy_summ = tf.summary.scalar("accuracy", accuracy)

		merged = tf.summary.merge_all()
		writer = tf.summary.FileWriter("DL_logs/eeg_cnn3/%s" % str(iterCV), sess.graph)

		sess.run(init)

		for epoch in range(training_epochs):
			sess.run(train, feed_dict={X:x_data, Y:y_data, p_keep_conv: DROPOUT_CONV, p_keep_hidden: DROPOUT_HIDDEN})

			#summary = sess.run(merged, feed_dict={X:x_data, Y:y_data, p_keep_conv: DROPOUT_CONV, p_keep_hidden: DROPOUT_HIDDEN})
			#writer.add_summary(summary)

			if epoch % display_step == 0:
				accuracy_tmp1 = accuracy.eval({X:x_data, Y:y_data, p_keep_conv: 1.0, p_keep_hidden: 1.0})
				accuracy_tmp2 = accuracy.eval({X:test_x_data, Y:test_y_data, p_keep_conv: 1.0, p_keep_hidden: 1.0})
				print str(iterCV) + "_Epoch:", '%04d' % (epoch+1), sess.run(cost, feed_dict={X:x_data, Y:y_data, p_keep_conv: 1.0, p_keep_hidden: 1.0}), accuracy_tmp1, accuracy_tmp2



			hypothesisVec = sess.run(hypothesis, feed_dict={X:test_x_data, Y:test_y_data, p_keep_conv: 1.0, p_keep_hidden: 1.0})
			if epoch +1== training_epochs:

				fw.write("\n\n" + str(iterCV) + " th data: " + str(epoch+1)+" epoch\naccuracy: " + str(accuracy_tmp1) + "(train)  " + str(accuracy_tmp2) + "(test)\n\n")
				for i in range(len(hypothesisVec)):
					fw.write(str(i+1) + "\t" +str(epoch+1)+" epoch"+"\t"+str(hypothesisVec[i][0]) + "\t" + str(math.floor(hypothesisVec[i][0]+0.5)) + "\t" + str(test_y_data[i][0]) + "\t" + str(math.floor(hypothesisVec[i][0]+0.5)==test_y_data[i][0]) + "\n")



		#correct_prediction = tf.equal(tf.floor(hypothesis+0.5), Y)
		#accuracy = tf.reduce_mean(tf.cast(correct_prediction, "float"))

		print "Optimization Finished"

		finalAccuracy = accuracy.eval({X:test_x_data, Y:test_y_data, p_keep_conv: 1.0, p_keep_hidden: 1.0})


	fw.close() ##for prediction results print out --> close


	return finalAccuracy


if __name__ == '__main__':


	X, Y, hypothesis, cost, train, init, p_keep_conv, p_keep_hidden = define_DBN()


	accuracyVec = []
	for i in range(10): #k-fold cross validation, k=10
		trainFile = "[full path of data directory]" + str(i+1) + "[suffix of training file name]" #eg. [file path directory]/1_train, 2_train, .... 10_train
		testFile  = "[fill path of data directory]" + str(i+1) + "[suffix of test file name]" #eg. [file path directory]/1_test, 2_test, .... 10_test
		print i+1
		accuracy = DBN_learning(i+1, trainFile, testFile, X, Y, hypothesis, cost, train, init, p_keep_conv, p_keep_hidden)
		accuracyVec.append(accuracy)
		print accuracyVec, np.mean(accuracyVec)

