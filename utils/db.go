package utils

import (
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"os"
)

func GetDB() (*gorm.DB, error) {
	dsn := os.Getenv("DB_DSN")
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})

	return db, err
}
