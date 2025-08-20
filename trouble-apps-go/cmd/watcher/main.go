package main

import (
	"trouble-app/internal/logging/log"
	"trouble-app/internal/lsof"
	"trouble-app/internal/signals"
)

func main() {
	f := lsof.NewLockedFileOrDie("/locks/lockfile.lock")
	defer f.Unlock()
	if err := f.Lock(); err != nil {
		log.Fatal().Err(err).Msg("Failed to lock")
	}

	<-signals.Channel()
}
