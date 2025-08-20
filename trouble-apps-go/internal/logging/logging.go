// Package logging provides useful routines for logging
package logging

import (
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
)

// LogLevel sets level of logging
func LogLevel(level string) {
	switch level {
	case "DEBUG":
		zerolog.SetGlobalLevel(zerolog.DebugLevel)
	case "INFO":
		zerolog.SetGlobalLevel(zerolog.InfoLevel)
	case "WARNING":
		zerolog.SetGlobalLevel(zerolog.WarnLevel)
	case "ERROR":
		zerolog.SetGlobalLevel(zerolog.ErrorLevel)
	default:
		log.Fatal().Msgf("Unsupported log Level: %s", level)
	}
}
