#include <bits/stdc++.h>
using namespace std;
double sigmoid(double);
string float_to_hex(double);

int main()
{
	fstream file;
	double dist = 0.0078125;
	double n = 0;
	vector<string> positive, negative;
	
	file.open("sigmoid.txt", ios::out);
	for (int i = 0; i < 1024; i++) {
		positive.push_back(float_to_hex(sigmoid(n)));
		negative.push_back(float_to_hex(sigmoid(-n)));
		n += dist;
	}
	for (int i = 0; i < 1024; i++)
		//file << positive[i] << ",\t" << (i % 20 == 0 ? "\n" : "");
		file << positive[i] << ",\n";
	for (int i = 0; i < 1024; i++)
		//file << negative[i] << ",\t" << (i % 20 == 0 ? "\n" : "");
		file << negative[i] << ",\n";


	file.close();



}

double sigmoid(double x)
{
	return (1 / (1 + exp(-x)));
}


string float_to_hex(double n) {//1 + 31 +32
	//convert floating point to 1 +  + 15  + 16 bits
	vector<int> number(32, 0);
	double current = 16384;
	number[0] = (n >= 0 ? 0 : 1);
	n = abs(n);
	for (int cnt = 1; cnt <= 31; cnt++) {
		if (n >= current) {
			n -= current;
			number[cnt] = 1;
		}
		else {
			number[cnt] = 0;
		}
		current /= 2;
	}

	//string ans = "32'h";
	string ans;
	for (int i = 0; i < 8; i++) {
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