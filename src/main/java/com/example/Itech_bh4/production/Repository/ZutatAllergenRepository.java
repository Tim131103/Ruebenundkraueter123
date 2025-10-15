package com.example.Itech_bh4.production.Repository;

import com.example.Itech_bh4.production.Entity.ZutatAllergen;
import com.example.Itech_bh4.production.Entity.IDKlasse.ZutatAllergenId;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ZutatAllergenRepository extends JpaRepository<ZutatAllergen, ZutatAllergenId> {
}
