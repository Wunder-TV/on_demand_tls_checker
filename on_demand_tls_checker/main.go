package main

import (
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"os"

	_ "github.com/go-sql-driver/mysql" // Import the MySQL driver
)

var db *sql.DB

func init() {
	// Read database configuration from environment variables
	dbUser := os.Getenv("DB_USER")
	dbPassword := os.Getenv("DB_PASSWORD")
	dbHost := os.Getenv("DB_HOST")
	dbPort := os.Getenv("DB_PORT")
	dbName := os.Getenv("DB_NAME")

	// Validate environment variables
	if dbUser == "" || dbPassword == "" || dbHost == "" || dbPort == "" || dbName == "" {
		log.Fatal("Missing required environment variables for database configuration")
	}

	// Create the DSN (Data Source Name)
	dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s", dbUser, dbPassword, dbHost, dbPort, dbName)

	// Connect to the database
	var err error
	db, err = sql.Open("mysql", dsn)
	if err != nil {
		log.Fatalf("Error connecting to the database: %v", err)
	}

	// Test the connection
	err = db.Ping()
	if err != nil {
		log.Fatalf("Error pinging the database: %v", err)
	}
}

func handler(w http.ResponseWriter, r *http.Request) {
	// Get the 'domain' query parameter
	domain := r.URL.Query().Get("domain")
	if domain == "" {
		http.Error(w, "Missing 'domain' query parameter", http.StatusBadRequest)
		return
	}

	// Prepare the SQL query with a WHERE clause to filter by domain
	query := `
		SELECT SUBSTRING_INDEX(url, 'https://', -1) AS trimmed_url 
		FROM sales_channel_domain 
		WHERE url LIKE ?
		LIMIT 1
	`

	// Use a prepared statement to safely insert the user input
	row := db.QueryRow(query, "%"+domain+"%")

	// Scan the result
	var trimmedURL string
	err := row.Scan(&trimmedURL)
	if err != nil {
		if err == sql.ErrNoRows {
			http.Error(w, "No matching results found", http.StatusNotFound)
			return
		}
		http.Error(w, fmt.Sprintf("Database error: %v", err), http.StatusInternalServerError)
		return
	}

	// Return the result to the user
	fmt.Fprintf(w, "200 - OK: %s\n", trimmedURL)
}

func main() {
	http.HandleFunc("/", handler)
	log.Println("Server is running on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
