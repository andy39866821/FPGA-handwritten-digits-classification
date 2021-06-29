import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import math
from keras.utils import np_utils
from keras.datasets import mnist
from keras.models import Sequential
from keras.models import model_from_json
from keras.layers import Dense

np.random.seed(10)

(x_train_image, y_train_label), (x_test_image, y_test_label) = mnist.load_data()
print('train data records=', len(x_train_image))
print('test data records=', len(x_test_image))

print('x_train image format=', x_train_image.shape)
print('y_train label format=', y_train_label.shape)


def plot_image(image):
    fig = plt.gcf()
    fig.set_size_inches(2, 2)
    plt.imshow(image, cmap='binary')
    plt.show()
    
def plot_images_labels_prediction(images, labels, prediction, idx, num=10):
    fig = plt.gcf()
    fig.set_size_inches(12, 14)
    if num > 25: 
        num = 25
    for i in range(0, num):
        ax = plt.subplot(5, 5, 1 + i)
        ax.imshow(images[idx], cmap='binary')
        title = "label=" + str(labels[idx])
        if len(prediction) > 0:
            title = title + ",prediction=" + str(prediction[idx])
        ax.set_title(title, fontsize=10)
        ax.set_xticks([])
        ax.set_yticks([])
        idx+=1
    plt.show()
    
def show_train_history(train_history, train, validation):
    plt.plot(train_history.history[train])
    plt.plot(train_history.history[validation])
    plt.title('Train History')
    plt.ylabel('train')
    plt.xlabel('Epoch')
    plt.legend(['train', 'validation'], loc='upper left')
    plt.show()


x_Train = x_train_image.reshape(60000, 784).astype('int64')
x_Test = x_test_image.reshape(10000, 784).astype('int64')

x_Train_normalize = (x_Train > 0) + 0
x_Test_normalize = (x_Test > 0) + 0


y_TrainOneHot = np_utils.to_categorical(y_train_label)
y_TestOneHot = np_utils.to_categorical(y_test_label)

model = Sequential()
model.add(Dense(units=64, input_dim=784, kernel_initializer='normal', activation='relu'))
model.add(Dense(units=10, kernel_initializer='normal', activation='sigmoid'))
print(model.summary())
model.compile(loss='categorical_crossentropy', optimizer='adam', metrics=['acc'])
train_history = model.fit(x=x_Train_normalize, y=y_TrainOneHot, validation_split=0.2, epochs=10, batch_size=200, verbose=2)



#show_train_history(train_history, 'acc', 'val_acc')
#show_train_history(train_history, 'loss', 'val_loss')
scores = model.evaluate(x_Test_normalize, y_TestOneHot)
print("")
print('Accuracy=', scores[1])

weights = model.layers[0].get_weights() # Getting params
input_layer_parameter = np.zeros((len(weights[0]) + 1,len(weights[0][0])))
for i in range(len(weights[0])):
    for j in range(len(weights[0][0])):
        input_layer_parameter[i][j] = weights[0][i][j]
for i in range(len(weights[1])):
    input_layer_parameter[len(weights[0])][i] = weights[1][i]

np.savetxt('input_layer_weight.txt', input_layer_parameter, fmt='%.5f')


weights = model.layers[1].get_weights() # Getting params
hidden_layer_parameter = np.zeros((len(weights[0]) + 1,len(weights[0][0])))
for i in range(len(weights[0])):
    for j in range(len(weights[0][0])):
        hidden_layer_parameter[i][j] = weights[0][i][j]
for i in range(len(weights[1])):
    hidden_layer_parameter[len(weights[0])][i] = weights[1][i]

np.savetxt('hidden_layer_weight.txt', hidden_layer_parameter, fmt='%.5f')

number = np.zeros(784)
for i in range(784):
    number[i] = x_Test_normalize[1][i]
plot_image(x_test_image[1])
np.savetxt('number.txt', number, fmt='%.0f')



# testing neural network
def testing_NN(input,input_lebel,input_layer_parameter,hidden_layer_parameter):
    hidden_activation = np.zeros(64)  
    output_activation = np.zeros(10)
    index = 0
    for i in range(0,64):
        for j in range(0,784):
            hidden_activation[i] += input[j] * input_layer_parameter[j][i]
        hidden_activation[i] += input_layer_parameter[784][i]
        if(hidden_activation[i] < 0): #ReLU
            hidden_activation[i] = 0
        #print("hidden activation ", i ," ")
        #print(input_layer_parameter[0][i],input_layer_parameter[784][i])
        #print(hidden_activation[i]*256)
    for i in range(0,10):
        for j in range(0,64):
            output_activation[i] += hidden_activation[j] * hidden_layer_parameter[j][i]
        output_activation[i] += hidden_layer_parameter[8][i]
        output_activation[i] = 1 / (1 + 2.718 ** (-output_activation[i]))
        #print("output activation ", i ," ")
        #print(output_activation[i]*256)
        if(output_activation[index] < output_activation[i]):
            index = i
        #print("predict : " , index)
        #print("answer  : " , input_lebel)

    return (index == input_lebel)


success = 0
for i in range(30):
    if(testing_NN(x_Test_normalize[i],y_test_label[i],input_layer_parameter,hidden_layer_parameter) == True):
        success +=1
    
print(success / 30)

        


