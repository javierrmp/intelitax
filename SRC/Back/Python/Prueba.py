import time

run = input("Start? > ")
print("*****************************")
mins = 0
# Only run if the user types in "start"
if run == 1:
    # Loop until we reach 20 minutes running
    while mins != 3:
        print(">>>>>>>>>>>>>>>>>>>>>", mins)
        # Sleep for a minute
        time.sleep(60)
        # Increment the minute total
        mins += 1
    # Bring up the dialog box here