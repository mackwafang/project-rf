function choose_weight(samples, weights, count=1) {
	///@function choose_weight
	///@description choose a random amount of sample items based on its weights
	///@param samples		array of items to select from
	///@param weights		(Optional) array of weights. if empty array or undefined, then all weights are set to 1
	///@param count			(Optional) amount of items to return. Must be larger equal 0. Defaults to 1
	assert(typeof(samples) == "array");
	assert(array_length(samples) != 0);
	assert(count > 0);
	if (is_undefined(weights)) {weights = array_create(array_length(samples), 1);}
	if (array_length(weights) == 0) {weights = array_create(array_length(samples), 1);}
	
	var total_weight = 0;
	for (var i = 0; i < array_length(weights); i++) {
		total_weight += weights[i];
	}
	
	var chosen_samples = [];
	for (var i = 0; i < count; i++) {
		var random_number = random(total_weight);
		var current_weight = 0;
		for (var j = 0; j < array_length(samples); j++) {
			current_weight += weights[j];
			if (random_number < current_weight) {
				array_push(chosen_samples, samples[j]);
				break;
			}
		}
	}
	return chosen_samples;
}