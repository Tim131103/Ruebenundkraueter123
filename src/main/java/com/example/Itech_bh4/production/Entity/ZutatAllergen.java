package com.example.Itech_bh4.production.Entity;

import com.example.Itech_bh4.production.Entity.IDKlasse.ZutatAllergenId;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(name = "ZUTATALLERGEN")
@IdClass(ZutatAllergenId.class)
public class ZutatAllergen {

    @Id
    @Column(name = "ALLERGENNR")
    private Integer allergenNr;

    @Id
    @Column(name = "ZUTATENNR")
    private Integer zutatenNr;
}
