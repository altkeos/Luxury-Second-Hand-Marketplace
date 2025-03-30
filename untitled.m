function [appr_decl, usernames, passwords] = logIn(usernames, passwords)
    username = input("Enter your username: ", 's');
    password = input("Enter your password: ", 's');
    
    if ismember(username, usernames)
        idx = find(strcmp(usernames, username));
        if strcmp(password, passwords(idx))
            appr_decl = true;
        else
            disp("The Password is Incorrect.");
            appr_decl = false;
        end
    else
        disp("Seems like you don't have an account");
        askSignUp = input("Would you like to sign up (Y/N):", 's');
        if askSignUp == "y" || askSignUp == "Y"
            [appr_decl, usernames, passwords] = signUp(usernames, passwords);
        else
            appr_decl = logIn(usernames, passwords);
        end
    end
end

function [appr_decl, usernames, passwords] = signUp(usernames, passwords)
    username = input("Enter your username: ", 's');
    password = input("Enter your password: ", 's');
    confPassword = input("Reenter your password: ", 's');
    policyConf = input("I agree to the terms and conditions(Y/N):");
    while policyConf == Y
        if strcmp(confPassword, password)
            if ismember(username, usernames)
                disp("The username already exists, please use another username.");
                [appr_decl, usernames, passwords] = signUp(usernames, passwords);
            else
                usernames(end+1) = username;
                passwords(end+1) = password;
                appr_decl = true;
            end
        else
            disp("The passwords don't match, try again.");
            [appr_decl, usernames, passwords] = signUp(usernames, passwords);
        end
    end
end

function searchListings()
    % Load listings from file
    if ~exist('listings.mat', 'file')
        error('listing.mat file not found. Please add items first.');
    end
    
    load('listings.mat', 'listings');
    
    % Get user search query
    query = lower(input('\nEnter your search query:\n> ', 's'));
    
    % Initialize search parameters
    keywords = "";
    priceLimit = inf;
    location = "";
    conditionFilter = "";
    categoryFilter = "";
    
    % Parse condition filter if specified
    if contains(query, "in ") && contains(query, "condition")
        condStart = strfind(query, 'in ');
        condEnd = strfind(query, 'condition');
        conditionFilter = strtrim(extractBetween(query, condStart+3, condEnd-1));
        query = erase(query, ['in ' conditionFilter ' condition']);
    end
    
    % Parse category filter if specified
    if contains(query, "category ") || contains(query, "type ")
        if contains(query, "category ")
            [query, categoryFilter] = extractFilter(query, "category ");
        else
            [query, categoryFilter] = extractFilter(query, "type ");
        end
    end
    
    % Parse price limit and location if specified
    if contains(query, "under")
        parts = split(query, "under");
        keywords = strtrim(parts(1));
        remQuery = strtrim(parts(2));
        tokens = regexp(remQuery, '(\d+)', 'tokens');
        if ~isempty(tokens)
            priceLimit = str2double(tokens{1}{1});
        end
        
        if contains(remQuery, "near")
            locParts = split(remQuery, "near");
            location = strtrim(locParts(2));
        end
    elseif contains(query, "near")
        parts = split(query, "near");
        keywords = strtrim(parts(1));
        location = strtrim(parts(2));
    else
        keywords = strtrim(query);
    end
    
    % Display parsed search parameters
    fprintf('\nSearch Parameters:\n');
    fprintf('  Keywords: %s\n', char(keywords));
    fprintf('  Max Price: $%.2f\n', priceLimit);
    if ~isempty(location)
        fprintf('  Location: %s\n', char(location));
    end
    if ~isempty(conditionFilter)
        fprintf('  Condition: %s\n', char(conditionFilter));
    end
    if ~isempty(categoryFilter)
        fprintf('  Category: %s\n', char(categoryFilter));
    end
    fprintf('\n');
    
    % Initialize scores array
    scores = zeros(length(listings), 1);
    matchedItems = false(length(listings), 1);
    
    % Score each item based on search criteria
    for i = 1:length(listings)
        score = 0;
        
        % Check name/keyword match
        if contains(lower(listings(i).ItemName), keywords)
            score = score + 2;
        end
        
        % Check price limit
        if listings(i).Price <= priceLimit
            score = score + 1;
        end
        
        % Check location match
        if ~isempty(location) && contains(lower(listings(i).Location), location)
            score = score + 1;
        end
        
        % Check condition match
        if ~isempty(conditionFilter) && strcmpi(listings(i).Condition, conditionFilter)
            score = score + 1;
        end
        % Check category match (if field exists)
        if isfield(listings, 'Category') && ~isempty(categoryFilter) && ...
           contains(lower(listings(i).Category), lower(categoryFilter))
            score = score + 1;
        end
        scores(i) = score;
        matchedItems(i) = (score > 0);
    end
    
    % Filter and sort items
    if ~any(matchedItems)
        fprintf('No items match your search criteria.\n');
        return;
    end
    
    [~, idx] = sort(scores(matchedItems), 'descend');
    sortedItems = listings(matchedItems);
    sortedItems = sortedItems(idx);
    
    % Display search results
    fprintf('Found %d matching items:\n', length(sortedItems));
    for i = 1:length(sortedItems)
        fprintf('\nItem %d (Relevance: %d):\n', i, scores(idx(i)));
        fprintf('  Name: %s\n', sortedItems(i).ItemName);
        fprintf('  Price: $%.2f\n', sortedItems(i).Price);
        fprintf('  Condition: %s\n', sortedItems(i).Condition);
        fprintf('  Location: %s\n', sortedItems(i).Location);
        if isfield(sortedItems, 'Category')
            fprintf('  Category: %s\n', sortedItems(i).Category);
        end
        fprintf('  Seller: %s (Verified: %s)\n', ...
                sortedItems(i).UserName, sortedItems(i).Verified);
    end
end

function [remainingQuery, filterValue] = extractFilter(query, filterType)
    filterStart = strfind(query, filterType);
    remainingParts = strsplit(query(filterStart(1)+length(filterType):end));
    filterValue = remainingParts{1};
    remainingQuery = strtrim(strrep(query, [filterType filterValue], ''));
end


function addItemToListings()
    % Load existing listings or create new file
    if exist('listings.mat', 'file')
        load('listings.mat', 'listings');
    else
        listings = struct('ItemName', {}, 'Price', {}, 'Condition', {}, ...
                         'Location', {}, 'UserName', {}, 'Verified', {});
    end
    
    % Collect item details via command line
    fprintf('\n=== Add New Item ===\n');
    new_item.ItemName = input('Item name: ', 's');
    new_item.Price = input('Price ($): ');
    new_item.Condition = input('Condition (New/Used/Refurbished): ', 's');
    new_item.Location = input('Location: ', 's');
    new_item.UserName = input('Your username: ', 's');
    new_item.Verified = input('Verified seller? (Yes/No): ', 's');
    
    % Add to listings
    listings(end+1) = new_item;
    
    % Save to file
    save('listings.mat', 'listings');
    fprintf('\nItem "%s" added successfully!\n', new_item.ItemName);
end

% Main program
%usernames = ["hello", "bye"];
%passwords = ["1234", "123456"];
%[success, usernames, passwords] = logIn(usernames, passwords);

sellItem()
