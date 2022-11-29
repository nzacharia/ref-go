package handler

import (
	"fmt"
	"net/http"
)

func Router() http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("/hello", handleHello)
	return mux
}

func handleHello(w http.ResponseWriter, r *http.Request) {
	nameParam := r.URL.Query().Get("name")
	if nameParam != "" {
		fmt.Fprintf(w, "Hello %s !", nameParam)
	} else {
		fmt.Fprintf(w, "Hello world!")
	}
}
