% Transaction System in MATLAB

% Sample listing database (stored as a struct array)
listings = struct('Item', {'Used Laptop', 'iPhone X', 'Gaming Chair'}, ...
                  'Price', {500, 300, 150}, ...
                  'Condition', {'Like New', 'Good', 'Fair'}, ...
                  'Location', {'Toronto', 'Mississauga', 'Vaughan'}, ...
                  'Seller', {'Anna', 'Mike', 'Sara'});

% Simulate selecting an item to message the seller
buyer_choice = input('Enter the number of the item you want to inquire about: ');
if buyer_choice < 1 || buyer_choice > length(listings)
    disp('Invalid selection. Please restart the process.');
    return;
end
fprintf('You selected %s.\n', listings(buyer_choice).Item);

% Simulate sending a message to the seller
disp('Messaging the seller...');
pause(1); % Simulate delay
fprintf('Message to %s: "Hi, is this available?"\n', listings(buyer_choice).Seller);

% Enter payment information
first_name = input('Enter your first name: ', 's');
last_name = input('Enter your last name: ', 's');

% Validate 16-digit credit card number
while true
    payment_card = input('Enter a 16-digit credit card number: ', 's');
    if length(payment_card) == 16 && all(isstrprop(payment_card, 'digit'))
        break;
    else
        disp('Invalid card number. Please enter exactly 16 digits.');
    end
end

% Validate 3-digit CVV code
while true
    cvv_code = input('Enter a 3-digit CVV code: ', 's');
    if length(cvv_code) == 3 && all(isstrprop(cvv_code, 'digit'))
        break;
    else
        disp('Invalid CVV. Please enter exactly 3 digits.');
    end
end

% Combine first and last name
payment_name = strcat(first_name, ' ', last_name);

% Confirming the purchase
disp('Processing transaction...');
pause(2); % Simulate delay
fprintf('Transaction Successful!\nThank you, %s, for purchasing %s for $%d.\n', payment_name, listings(buyer_choice).Item, listings(buyer_choice).Price);

% Display order receipt
disp('--- ORDER RECEIPT ---');
fprintf('Buyer: %s\nItem: %s\nPrice: $%d\nSeller: %s\nLocation: %s\n', payment_name, listings(buyer_choice).Item, listings(buyer_choice).Price, listings(buyer_choice).Seller, listings(buyer_choice).Location);
disp('----------------------');

disp('Thank you for using our marketplace!');
