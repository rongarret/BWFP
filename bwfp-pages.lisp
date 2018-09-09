
(ensure-http-server 1234)

(defpage "/hello"
  (bb input (textinput :t1)
      value (value input)
      (if value
        (htm "Hello " value)
        (htm "What is your name?" (:form input)))))


(defpage "/add"
  (bb input1 (textinput :t1)
      input2 (textinput :t2)
      value1 (value input1)
      value2 (value input2)
      (htm (:form input1 " plus " input2 (:input :type :submit))
           " equals "
           (str
            (if (and value1 value2)
              (+ (parse-integer value1) (parse-integer value2))
              "?")))))
