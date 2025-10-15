package com.example.Itech_bh4.production.Entity;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

@Table(name = "ALLERGEN")
@Entity
@Getter
@Setter
public class Allergen {
    @Id
    private Integer allergenNr;
    private String allergenName;
    
}