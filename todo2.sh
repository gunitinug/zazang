# Function to edit a todo item
edit_todo() {
    local line_num
    line_num=$(whiptail --inputbox "Enter the line number of the todo item to edit:" 8 40 "" --title "Edit Todo" 3>&1 1>&2 2>&3)
    if ! [[ $line_num =~ ^[0-9]+$ ]]; then
        whiptail --msgbox "Invalid input. Please enter a number." 8 40
        return
    fi

    local todo_entry
    todo_entry=$(sed -n "${line_num}p" todos.txt)
    if [ -z "$todo_entry" ]; then
        whiptail --msgbox "No todo item found at line $line_num." 8 40
        return
    fi

    local priority time tag description
    priority=$(echo "$todo_entry" | cut -d'|' -f1)
    time=$(echo "$todo_entry" | cut -d'|' -f2)
    tag=$(echo "$todo_entry" | cut -d'|' -f3)
    #description=$(echo "$todo_entry" | cut -d'|' -f4)	# no need for validation.

    #local new_priority new_time new_tag new_description
    local new_priority new_time new_tag
    new_priority=$(whiptail --inputbox "Enter new priority (1, 2, or 3):" 8 40 "$priority" --title "Edit Todo" 3>&1 1>&2 2>&3)
    new_time=$(whiptail --inputbox "Enter new time (YYYY-MM-DD HH:MM:SS):" 8 40 "$time" --title "Edit Todo" 3>&1 1>&2 2>&3)
    new_tag=$(whiptail --inputbox "Enter new tag for the todo item:" 8 40 "$tag" --title "Edit Todo" 3>&1 1>&2 2>&3)
    new_description=$(whiptail --inputbox "Enter new description for the todo item:" 8 40 "$description" --title "Edit Todo" 3>&1 1>&2 2>&3)

    # Validate new_time and new_tag as well.	HOPEFULLY THE LAST PART!!!!
    # Validate new priority
    if [[ ! $new_priority =~ ^[1-3]$ ]]; then
        whiptail --msgbox "Invalid priority. Please enter a priority between 1 to 3." 8 40
        return
    fi
    # Validate new time
    if ! date -d "$new_time" &>/dev/null; then
    	whiptail --msgbox "Invalid time. Please enter time in YYYY-MM-DD HH:MM:SS format." 8 40
        return
    fi  
    # Validate new tag
    if ! [[ $new_tag =~ ^[A-Za-z]+$ ]]; then
    	whiptail --msgbox "Invalid tag. Please enter tag as A-Z case insensitive." 8 40
        return
    fi         
    #Validate new description
    if ! [[ $new_description =~ ^.+$ ]]; then	# just check it's not empty.
    	whiptail --msgbox "Invalid description. Please enter a valid description." 8 40    
    	return
    fi

    # Update todo item in file
    sed -i "${line_num}s/.*/$new_priority|$new_time|$new_tag|$new_description/" todos.txt
    whiptail --msgbox "Todo item edited successfully." 8 40
}

# Function to delete a todo item
delete_todo() {
    local line_num
    line_num=$(whiptail --inputbox "Enter the line number of the todo item to delete:" 8 40 "" --title "Delete Todo" 3>&1 1>&2 2>&3)
    if ! [[ $line_num =~ ^[0-9]+$ ]]; then
        whiptail --msgbox "Invalid input. Please enter a number." 8 40
        return
    fi

    local todo_entry
    todo_entry=$(sed -n "${line_num}p" todos.txt)
    if [ -z "$todo_entry" ]; then
        whiptail --msgbox "No todo item found at line $line_num." 8 40
        return
    fi

    # Delete todo item from file
    sed -i "${line_num}d" todos.txt
    whiptail --msgbox "Todo item deleted successfully." 8 40
}

