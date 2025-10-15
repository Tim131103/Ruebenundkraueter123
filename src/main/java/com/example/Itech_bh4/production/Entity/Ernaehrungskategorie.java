package com.example.Itech_bh4.production.Entity;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "ERNAEHRUNGSKATEGORIE")
@Getter
@Setter
public class Ernaehrungskategorie {

    @Id
    private Integer ernaehrungskategorieNr;
    private String ernaehrungskategoriename;

}