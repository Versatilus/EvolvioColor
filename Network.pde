/*
 *
 * Original by Charles Fried - 2017
 * ANN Tutorial
 * Part #2
 *
 */
class Network {
	float[] input;
	int[] networkShape;

	NetworkLayer[] layers;

	float learningRate = 0.0001;
	// int bestIndex = 0;

	Network(int[] _shape) {
		networkShape = _shape;
		input = new float[networkShape[0]];
		for (int i = 0; i < input.length; ++i)
			input[i] = 0.;
		layers = new NetworkLayer[networkShape.length - 1];
		for (int i = 1; i < networkShape.length; ++i)
			layers[i - 1] = new NetworkLayer(networkShape[i - 1], networkShape[i]);
	}
	void forward(float[] inputs) {
		input = inputs;
		layers[0].activate(inputs);
		for (int i = 1, end = layers.length; i < end; ++i)
			layers[i].activate(layers[i - 1].activation);
		// float best = -909000.;
		//
		// for (int i = 0, end = layers[layers.length - 1].activation.length; i < end; ++i) {
		// float output = layers[layers.length - 1].activation[i];
		//
		// if (output > best) {
		// bestIndex = i;
		// best = output;
		// }
		// }
	}
	void train(float[] outputs) {
		float[] cost = new float[outputs.length];
		for (int i = 0, end = cost.length; i < end; ++i)
			cost[i] = (outputs[i] - layers[layers.length - 1].activation[i]) * learningRate;
		for (int i = layers.length - 1; i > 0; --i)
			cost = layers[i].propagateError(cost, false);
		layers[0].propagateError(cost, true);

		layers[0].adjustWeights(input);
		for (int i = 1, end = layers.length; i < end; ++i)
			layers[i].adjustWeights(layers[i - 1].activation);
	}
}

class NetworkLayer {
	int inputSize, outputSize;

	float[] weights;
	float[] bias;
	float[] activation;
	float[] error;
	float[] gradient;
	float[] mutability;

	NetworkLayer(int _in, int _out) {
		inputSize = _in;
		outputSize = _out;
		weights = new float[inputSize * outputSize];
		mutability = new float[inputSize * outputSize];
		bias = new float[outputSize];
		activation = new float[outputSize];
		gradient = new float[outputSize];
		for (int col = 0; col < outputSize; ++col)
			bias[col] = (float)(Math.random() * 4. - 2.);
		for (int row = 0; row < inputSize; ++row) {
			for (int col = 0; col < outputSize; ++col)
				weights[row * outputSize + col] = (float)((Math.random() * 2. - 1.) / inputSize);
		}
		for (int col = 0; col < outputSize; ++col)
			activation[col] = 0;
	}
	NetworkLayer(int _in, int _out, float[] _weights, float[] _bias) {
		inputSize = _in;
		outputSize = _out;
		weights = new float[inputSize * outputSize];
		bias = new float[outputSize];
		activation = new float[outputSize];
		gradient = new float[outputSize];
		for (int col = 0, end = (int)Math.min(outputSize, _bias.length); col < end; ++col)
			bias[col] = _bias[col];
		for (int row = 0, end = (int)Math.min(outputSize * inputSize, _weights.length); row < end;
		++row)
			weights[row] = _weights[row];
		for (int col = 0; col < outputSize; ++col)
			activation[col] = 0;
	}
	float[] activate(float[] input) {
		for (int col = 0; col < outputSize; ++col)
			activation[col] = input[0] * weights[col];
		for (int row = 1; row < inputSize; ++row) {
			for (int col = 0; col < outputSize; ++col)
				activation[col] += input[row] * weights[row * outputSize + col];
		}
		for (int col = 0; col < outputSize; ++col) {
			activation[col] += bias[col];
			if (activation[col] < 0)
				activation[col] *= .5;
		}
		return activation;
	}
	float[] propagateError(float[] previousError, boolean noError) {
		for (int col = 0; col < outputSize; ++col) {
			if (activation[col] < 0)
				gradient[col] = previousError[col] * .5;
			else
				gradient[col] = previousError[col];
		}
		if (noError) return gradient;
		float[] backError = new float[inputSize];
		for (int row = 0; row < inputSize; ++row)
			backError[row] = gradient[0] * weights[row * outputSize];
		for (int row = 0; row < inputSize; ++row)
			for (int col = 1; col < outputSize; ++col)
				backError[row] += gradient[col] * weights[row * outputSize + col];
		error = backError;
		return backError;
	}
	float[] adjustWeights(float[] input) {
		for (int row = 0; row < inputSize; ++row)
			for (int col = 1; col < outputSize; ++col)
				weights[row * outputSize + col] += gradient[col] * input[row];
		return weights;
	}
}
