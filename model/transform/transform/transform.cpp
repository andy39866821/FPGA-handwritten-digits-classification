#include <bits/stdc++.h>
using namespace std;
string float_to_hex(double);
bool testing_NN(vector<double>input, int input_lebel, vector<vector<double>>input_layer_parameter, vector<vector<double>>hidden_layer_parameter);

int main()
{

	fstream inputFile;
	fstream outputFile;
	double number;
	int cnt = 0;
	int count = 0;
	vector<double>input(784,0);
	vector<vector<double>>input_layer_parameter(785,vector<double>(64,0));
	vector<vector<double>>hidden_layer_parameter(65, vector<double>(10, 0));

	double max_n = 0, min_n = 0;
	inputFile.open("input_layer_weight.txt", ios::in);
	outputFile.open("input_layer_weight_verilog.txt", ios::out);

	outputFile << "memory_initialization_radix = 16;\n";
	outputFile << "memory_initialization_vector =\n";
	cout << "write pre word\n";
	while (!inputFile.eof()) {
		inputFile >> number;
		if(count < 64*785)
			input_layer_parameter[count / 64][count % 64] = number;
		count++;
		max_n = (number > max_n ? number : max_n);
		min_n = (number < min_n ? number : min_n);
		outputFile << float_to_hex(number) << ",\n";

	}
	cout << "max:" << max_n << " min:" << min_n << endl;
	inputFile.close();
	outputFile.close();

	max_n = min_n = 0;
	count = 0;
	inputFile.open("hidden_layer_weight.txt", ios::in);
	outputFile.open("hidden_layer_weight_verilog.txt", ios::out);

	outputFile << "memory_initialization_radix = 16;\n";
	outputFile << "memory_initialization_vector =\n";
	cout << "write pre word\n";
	while (!inputFile.eof()) {
		inputFile >> number;
		if (count < 65 * 10)
			hidden_layer_parameter[count / 10][count % 10] = number;
		count++;
		max_n = (number > max_n ? number : max_n);
		min_n = (number < min_n ? number : min_n);
		outputFile << float_to_hex(number) << ",\n";

	}
	cout << "max:" << max_n << " min:" << min_n << endl;
	cout << "hidden layer has : " << count << endl;
	inputFile.close();
	outputFile.close();


	count = 0;
	inputFile.open("number.txt", ios::in);
	outputFile.open("number_verilog.txt", ios::out);

	outputFile << "memory_initialization_radix = 2;\n";
	outputFile << "memory_initialization_vector =\n";
	while (!inputFile.eof()) {
		inputFile >> number;

		if (count < 784)
			input[count] = number;
		count++;
		outputFile << number << ",\n";
	}
	inputFile.close();
	outputFile.close();
	cout << testing_NN(input, 7, input_layer_parameter, hidden_layer_parameter);

}

string float_to_hex(double n) {
	//convert floating point to 1 +  + 5  + 10 bits
	n *= 1024;
	vector<int> number(16, 0);
	double current = 16384;
	number[0] = (n >= 0 ? 0 : 1);
	n = abs(n);
	for (int cnt = 1; cnt <= 15; cnt++) {
		if (n >= current) {
			n -= current;
			number[cnt] = 1;
		}
		else {
			number[cnt] = 0;
		}
		current /= 2;
	}

	string ans = "";
	for (int i = 0; i < 4; i++) {
		int num = 0;
		for (int j = 0; j < 4; j++) {
			num = num * 2 + number[i * 4 + j];
		}

		switch (num) {
		case 15:
			ans += "f";
			break;
		case 14:
			ans += "e";
			break;
		case 13:
			ans += "d";
			break;
		case 12:
			ans += "c";
			break;
		case 11:
			ans += "b";
			break;
		case 10:
			ans += "a";
			break;
		default:
			ans += (char)(num + 48);
			break;
		}

	}

	return ans;
}


bool testing_NN(vector<double>input, int input_lebel, vector<vector<double>>input_layer_parameter, vector<vector<double>>hidden_layer_parameter) {
	vector<double>hidden_activation(64, 0);
	vector<double>output_activation(10, 0);
	int index = 0;
	for (int i = 0; i < 64; i++) {
		for (int j = 0; j < 784; j++) {
			hidden_activation[i] += input[j] * input_layer_parameter[j][i];
		}
		hidden_activation[i] += input_layer_parameter[784][i];
		if (hidden_activation[i] < 0) //ReLU
			hidden_activation[i] = 0;
		cout << "hidden activation " << i << endl;
		cout << "	" << hidden_activation[i] * 1024 << endl;

	}
	for (int i = 0; i < 10; i++) {
		for (int j = 0; j < 64; j++) {
			output_activation[i] += hidden_activation[j] * hidden_layer_parameter[j][i];
		}
		output_activation[i] += hidden_layer_parameter[8][i];
		cout << "output activation " << i << endl;
		cout << "	" << output_activation[i] * 1024 << endl;
		if (output_activation[index] < output_activation[i])
			index = i;

	}


	cout << "predict : " << index << endl;
	cout << "answer  : " << input_lebel << endl;

	return (index == input_lebel);
}
