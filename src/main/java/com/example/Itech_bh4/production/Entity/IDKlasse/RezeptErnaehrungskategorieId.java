package com.example.Itech_bh4.production.Entity.IDKlasse;

import java.io.Serializable;
import java.util.Objects;

public class RezeptErnaehrungskategorieId implements Serializable {
    private Integer rezeptNr;
    private Integer ernaehrungskategorieNr;

    public RezeptErnaehrungskategorieId() {}

    public RezeptErnaehrungskategorieId(Integer rezeptNr, Integer ernaehrungskategorieNr) {
        this.rezeptNr = rezeptNr;
        this.ernaehrungskategorieNr = ernaehrungskategorieNr;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        RezeptErnaehrungskategorieId that = (RezeptErnaehrungskategorieId) o;
        return Objects.equals(rezeptNr, that.rezeptNr) &&
               Objects.equals(ernaehrungskategorieNr, that.ernaehrungskategorieNr);
    }

    @Override
    public int hashCode() {
        return Objects.hash(rezeptNr, ernaehrungskategorieNr);
    }
}
