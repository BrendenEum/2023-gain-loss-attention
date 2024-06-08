using CSV, DataFrames, Base.Threads

folders = ["results_RaDDM_Gain/146_trials/", "results_RaDDM_Loss/146_trials/"]

# -------------------------------------------
# Things to Change
file_path = folders[1]
models = 1:36 # iterate over models (24 for Add, 36 for Ref)
# -------------------------------------------

Threads.@threads for i in models

    @time begin
    
        # Progress
        println(i)

        # Read the CSV file
        df = CSV.File(file_path * "likelihoods_$(i).csv") |> DataFrame

        # Function to check if "RaDDM_likelihood" is present in the tuple
        function contains_raddm_likelihood(tuple_str)
            return occursin("RaDDM_likelihood", tuple_str)
        end

        # Filter rows where "RaDDM_likelihood" is missing from the first variable
        filtered_df = filter(row -> contains_raddm_likelihood(row.first), df)

        # Initialize the dictionary
        trial_likelihoods = Dict()

        # Iterate over each row in the dataframe
        for row in eachrow(filtered_df)
            # Parse the 'first' column which is a tuple-like string
            first_key = eval(Meta.parse(row.first))
            
            # Parse the 'second' column which is a dictionary-like string
            second_dict = eval(Meta.parse(row.second))
            
            # Add to the nested dictionary
            trial_likelihoods[first_key] = second_dict
        end

        ########################################

        trial_likelihoods_df = DataFrame()

        for (k,v) in trial_likelihoods
            cur_df = DataFrame(Symbol(i) => j for (i, j) in pairs(v))

            rename!(cur_df, :first => :trial_num, :second => :likelihood)

            # Unpack parameter info
            for (a, b) in pairs(k)
                cur_df[!, a] .= b
            end

            # Change type of trial num col to sort by
            cur_df[!, :trial_num] = [parse(Int, (String(i))) for i in cur_df[!,:trial_num]]

            sort!(cur_df, :trial_num)

            trial_likelihoods_df = vcat(trial_likelihoods_df, cur_df, cols=:union)
            append!(trial_likelihoods_df, cur_df, cols=:union)
        end

        CSV.write(file_path * "likelihoods_df_$(i).csv", trial_likelihoods_df);
    end
end