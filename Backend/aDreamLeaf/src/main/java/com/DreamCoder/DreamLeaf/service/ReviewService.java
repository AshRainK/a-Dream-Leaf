package com.DreamCoder.DreamLeaf.service;

import com.DreamCoder.DreamLeaf.dto.ReviewCreateDto;
import com.DreamCoder.DreamLeaf.dto.ReviewDto;
import com.DreamCoder.DreamLeaf.repository.ReviewRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Service
@Slf4j
@RequiredArgsConstructor
public class ReviewService {

    private final ReviewRepository reviewRepositoryImpl;

    public ReviewDto create(ReviewCreateDto reviewCreateDto){
        return reviewRepositoryImpl.save(reviewCreateDto);
    }

}
