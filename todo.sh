#!/bin/bash

# Function to add a todo item
add_todo() {
    local priority time tag description
    priority=$(whiptail --inputbox "Enter priority (1, 2, or 3):" 8 40 1 --title "Add Todo" 3>&1 1>&2 2>&3)
    time=$(date "+%Y-%m-%d %H:%M:%S")
    tag=$(whiptail --inputbox "Enter tag for the todo item:" 8 40 "" --title "Add Todo" 3>&1 1>&2 2>&3)
    description=$(whiptail --inputbox "Enter description for the todo item:" 8 40 "" --title "Add Todo" 3>&1 1>&2 2>&3)

    # Validate priority
    if [[ ! $priority =~ ^[1-3]$ ]]; then
        whiptail --msgbox "Invalid priority. Please enter a priority between 1 to 3." 8 40
        return
    fi

    # Save todo item to file
    echo "$priority|$time|$tag|$description" >> todos.txt
    whiptail --msgbox "Todo item added successfully." 8 40
}

# Function to list todo items
list_todos() {
    local sorted_by
    #sorted_by=$(whiptail --menu "Sort by:" 15 60 4 "Priority" "Sort by priority" "Time" "Sort by time added" "Tag" "Sort by tag" "Description" "Sort by description" 3>&1 1>&2 2>&3)
    sorted_by=$(whiptail --menu "Sort by:" 15 60 4 "As is" "No sorting" "Priority" "Sort by priority" "Time" "Sort by time added" "Tag" "Sort by tag" 3>&1 1>&2 2>&3)

    case $sorted_by in
    	"As is")
    	    whiptail --title "Todo List (As is)" --textbox todos.txt 20 70
    	    ;;
        "Priority")
            #whiptail --title "Todo List (Sorted by Priority)" --textbox <(sort -t '|' -k1 -n todos.txt) 20 70
            sort -t '|' -k1 -n todos.txt > temp_f
            whiptail --title "Todo List (Sorted by Priority)" --textbox temp_f 20 70
            ;;
        "Time")
            sort -t '|' -k2 todos.txt > temp_f
            whiptail --title "Todo List (Sorted by Time)" --textbox temp_f 20 70
            ;;
        "Tag")
            sort -t '|' -k3 todos.txt > temp_f
            whiptail --title "Todo List (Sorted by Tag)" --textbox temp_f 20 70
            ;;
        #"Description")
        #    whiptail --title "Todo List (Sorted by Description)" --textbox <(sort -t '|' -k4 todos.txt) 20 70
        #    ;;
        *)
            return
            ;;
    esac
}

# Function to search todo items
search_todos() {
    local search_by query
    search_by=$(whiptail --menu "Search by:" 15 60 3 "Priority" "Search by priority" "Time" "Search by time added" "Tag" "Search by tag" 3>&1 1>&2 2>&3)

    case $search_by in
        "Priority")
            query=$(whiptail --inputbox "Enter priority to search (1, 2, or 3):" 8 40 "" --title "Search Todo" 3>&1 1>&2 2>&3)
            if ! [[ $query =~ ^[0-9]+$ ]]; then
                whiptail --msgbox "Invalid input. Please enter a number." 8 40
                return
            fi
            #grep "^$query\|" todos.txt | whiptail --title "Search Result (Priority: $query)" --textbox - 20 70
            grep "^$query\|.+$" todos.txt > temp_f
            whiptail --title "Search Result (Priority: $query)" --textbox temp_f 20 70
            ;;
        "Time")
            query=$(whiptail --inputbox "Enter time (YYYY-MM-DD HH:MM:SS) to search:" 8 40 "" --title "Search Todo" 3>&1 1>&2 2>&3)
            #if ! [[ $query =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}$ ]]; then
            #    whiptail --msgbox "Invalid input format. Please enter time in YYYY-MM-DD HH:MM:SS format." 8 60
            #    return
            #fi
            if ! date -d "$query" &>/dev/null; then
                whiptail --msgbox "Invalid input format. Please enter time in YYYY-MM-DD HH:MM:SS format." 8 60
                return
            fi            
            #grep "^.+\|$query\|.+\|.+\$" todos.txt | whiptail --title "Search Result (Time: $query)" --textbox - 20 70
            grep "^.+\|$query\|.+\|.+$" todos.txt > temp_f
            whiptail --title "Search Result (Time: $query)" --textbox temp_f 20 70
            
            ;;
        "Tag")
            query=$(whiptail --inputbox "Enter tag to search:" 8 40 "" --title "Search Todo" 3>&1 1>&2 2>&3)
            if ! [[ $query =~ ^[A-Za-z]+$ ]]; then
                whiptail --msgbox "Invalid input. Please enter a valid tag." 8 40
                return
            fi
            #grep "\|$query\|.+\$" todos.txt | whiptail --title "Search Result (Tag: $query)" --textbox - 20 70
            grep "^.+\|.+\|$query\|.+$" todos.txt > temp_f
            whiptail --title "Search Result (Tag: $query)" --textbox temp_f 20 70
            ;;
        *)
            return
            ;;
    esac
}

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

# Main menu
while true; do
    choice=$(whiptail --menu "Todo Application Menu" 15 60 8 "Add Todo" "Add a new todo item" "List Todos" "List all todo items" "Search Todos" "Search todo items" "Edit Todo" "Edit a todo item" "Delete Todo" "Delete a todo item" "Exit" "Exit the application" 3>&1 1>&2 2>&3)

    case $choice in
        "Add Todo")
            add_todo
            ;;
        "List Todos")
            list_todos
            ;;
        "Search Todos")
            search_todos
            ;;
        "Edit Todo")
            edit_todo
            ;;
        "Delete Todo")
            delete_todo
            ;;
        "Exit")
            exit 0
            ;;
        *)
            whiptail --msgbox "Invalid choice. Please try again." 8 40
            ;;
    esac
done

