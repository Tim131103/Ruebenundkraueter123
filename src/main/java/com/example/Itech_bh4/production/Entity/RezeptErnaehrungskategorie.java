package com.example.Itech_bh4.production.Entity;

import com.example.Itech_bh4.production.Entity.IDKlasse.RezeptErnaehrungskategorieId;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "REZEPTERNAEHRUNGSKATEGORIE")
@IdClass(RezeptErnaehrungskategorieId.class)
public class RezeptErnaehrungskategorie {

    @Id
    @Column(name = "REZEPTNR")
    private Integer rezeptNr;

    @Id
    @Column(name = "ERNAEHRUNGSKATEGORIENR")
    private Integer ernaehrungskategorieNr;
}
