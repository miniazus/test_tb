function bin_array = CreateRan512b(num_sample, num_bit)
    % Preallocate string array
    bin_array = strings(1, num_sample);
    
    for k = 1:num_sample
        rand_bits = randi([0 1], 1, num_bit);   % 1×num_bit vector
        bin_array(k) = sprintf('%d', rand_bits); % store as string
    end
end