---
author: riceball
date: 2011-03-18 07:37:26+00:00
title: HTML Web游戏开发之浮光掠影
categories:
- Game Development
- HTML5
tags:
- html5
- h5
- 2d
- 3d
- webgl
- game
- engine
- development
---

![](data:image/jpg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAkGBhMSEBUUEhQVFBUVFxYZGBcYFxwdGBsWGBcWGBwXGRwXHCYfGR0kGhgVHy8hIygpLCwsFx8xNTAqNSYrLCkBCQoKDgwOGg8PGiwlHyQsLCwsLCwqLCwsLCwsLCwsLCwsLCwsLCwpLDU0LCwsLCwpLCwsLCwpLCwsLCksLCwsLP/AABEIAMwAzAMBIgACEQEDEQH/xAAcAAABBQEBAQAAAAAAAAAAAAAFAAMEBgcIAgH/xABMEAACAQIEAwUEBgcGAggHAAABAgMAEQQSITEFBkETIlFhgQcycZFCUqGxwdEUIzNicuHwJFOCkqKyFkMVJTVzg7PC0ggXNFRjdPH/xAAZAQADAQEBAAAAAAAAAAAAAAAAAgMBBAX/xAAtEQACAgICAgAFAgYDAAAAAAAAAQIRAyESMUFREyIyYaFxwQSBkdHh8CNCsf/aAAwDAQACEQMRAD8A3GlSpUAKlSpUAKlSpUAKlXl3AFzVM5s9q2CwNw0geT6iat6jp60AXQmouJ4pFGCXdQB4msD4r7XuJYwkYSMQR/WaxNvie6Pt+NU3iLq5zYzGPM31VJb79B6UAdC8R9rvDoTZp1J8FOb/AG3oHiPb5gfoLM3wj/M1hQ4vhk/Z4fN5u34Cl/xTL9CONfgl/voA2v8A+fMR2gnP+Ff/AHVIg9uUB96GYf4R+DVhv/EWMO32IPypf8R4sb/ag/KgDojC+2PAtuXT+JCKsPDecMLP+zlQ+Vxf5b1ywvNsv040P+G1SoOaYj7yFT4g0AdaxzK2xBr3XN/BOe5Y/wBhiCR9Vjf7G/A1oPAfa4NFxK2P1hqPUbj7aANPpVC4bxiKdQ0TqwPgam0AKlSpUAKlSpUAKlSpUAKlSpUAKlSpUAKhPMPM0GDiMk7hFHifsHifIUK585/g4bCWc3c3CIN2P5eJ6Vzvxni8+Pc4rHSFYQTkQdf3UH3saALRzT7WMZxF2iwQMMI3fZiPEnZB8NaozzYeAk//AFMvVj+zB+9qj4rijzWihXJGNkX72PX1r1gOF3NkXtX6n/lr8T9I0AeJ8biMRuSEHT3UA+6lg+EhzZc8zeEa6erGrhw3lJTZsQe0PRdkHwUVb8LHFEmyoo+AA/AVCeZLovHC32Z3heUsQfdhjj83uzflRvBezzEvvNl/hQCr/gpI5BdCrDa6kEX8LjrRrAxAVCWaZVYY0UDDexyR98TL8x+VesR7F5193FSetj+Va3hpABUkSXpFlyX2YscfRgeN9l3EE910l8mT/wDtV3iXKuJiBM+Da3Vo7/drXUSgUpYI2FiBVVmkI8cTkH9CjY/q5MrfVfQ38L7U+nEZ4NHBK+f4GuguaPZnhMUCcgDfWGh+YrLOYPZvi8GC0X6+LqjDUfD+VqvHLF9iPFJdEPl7nKSJw0EhVuqE7/ga2Tkv2qRYkiKa0cu2uxPlfr5ffXObYNZCezukg3jbQ38vypzD8TIOWW4I2f6Q+PiKqSOyUcEXFeqw72e+1ZoWWDGNdGsEl6fAn+rVtsE4dQym4NADlKlSoAVKlSoAVKlSoAVVfn3neLh2GMjm7HREG7N0A/PpRvjHFUw8LyyMFVASSdgAK5g5i5gbimLfEzkrhovdXy6KP3m6/wAqAIfEOIvipGxuOJYE/q4/rW2UDog6nrQaeeTEuWchVX/Ki9AB+FLFYlsTLc91FGg+iiD+vWrDwTgYkQuRaNMpRPrXNi7ef2CsckuzUrBWAwbyOI4ozkupa5sWBOhc7hbA6CtLx/L7YNsjQrFe5UIwZLXt3Tv6EdRVc4YbYqW22WIf6GNaP7RyS0P/AIn+5ajKVlI6aKzFrUzIrKVIuCLG/wDWlQIWtvU2FrnTzPyBP4Vzs6osK8IwyxoqIAqjYDYa3/GjmHY3oFg5KPYK5rjnJpnRFKgpETavkWLN2v0Nh/lU+Pn5VLwwFtaiNCA8llIuVOb63cA0+FrUQyd2TtN0OycQtUCTGNm3r5NDfTag+LLKbXrZZFIfgWXDY23nUHEuHkzNqBey9Nf6PzqvrxBhpSHETVFH0TqgTzpyDDiQZIxkk6MPx8ayviGDZG7LEizDRZfH+L863OHifQ0F5i5fjxYC5QCxAv11IFdeKbjp9EMkE9oxlJDETHKLof6zKa1b2Xe0lsNImFxL5on0hlP2I1ULjvAHw0rYaf6Jsj+HgD5fdQWB8hMMvuk7/VPRhXWch2fHIGAI2Neqyj2O8+tKpweJa80Q7rE/tI+jDxI0v6Vq9ACpUqVACpE0qDc28cXCYSWZjYIpPxsNAPMmw9aAMh9t/NzTzJw+A7kGW3+lT/uPpWWcaxA7uGi1SPQ2+lJ1b8KmjiD5ZsbIbyzMwT4tqxHwGlCcBGQC/wBInKnx3ZvQUAS4cNlyix7NWHaOFzAuNcp1Gg2360dkiCyB0YRhUz2N20LWsQLaknW21hVowHDYY2w0UhYgItolFmbtc2rad5tGNfOKcmC4/RW7VWbKYSLSgWZipG52Oo+21ccpOTteC3DjsEcGxCPI8q3AkyWUq5IyqV1yqRre9Wzj/OEWJdECOtswzkEIGdlsCWAtex8tqH8IAiRYirgopUgsUsMpOzEG/T5HYaWfl3Ch5njdVKtEwsUsp2PXe2h209aomjLK/HhT4VKigI2+Hz0/GnuK8qyyTQyI+UIe8pJtY9QBudhrRPiGCRUAZlW7Ja7W2dSfsvU5R0Wi9jOEiPWrFw4CvGHwAOo1v1G1FMPgrW6dB8a4ssGX5qj5HNZh0vtrvU6c9xfX76qPMONV3jVGF1cFhcX99U0t5t1q38VS0DHwDfbSrA4r9V+6IykrRCkw4NVOdJDjnjsMiwqw8dWI/wDd8h41bOCqTh4/h9gJA38rUBf/ALWdfHCr9jk/jSRxSUmVWToFz4M9sAb6xXGn759KZxGCYbVPx+Ic8QRbaAKnX3dR4289utOcTweJ7RQkcRDXsxcgiwF7jL5+PSu9Y3r9BHkVAQEjen4J8rAnQAg+gINF5OGg5huyi5A8SLimZeBkrvb3T9oq1asTkivc74VcYzCFDbvMAdxZVDXY6XNlOUXNzqelZZxHAFltuyi6n6y+HxFbBHgc0sJJyr2juijXVcMCQfAEkn0qncY5eEUMLIpGZMxvuHJN7g7Am49POnxy8Mlkj5RT+B8XkjdJYzabDnMv7yD3kPpf5muquUOYkxuEjmQ6OoPwPUHzBuPSuTOIRmGYOugOv5itV9iHMvZYl8IT+rmHaxeAP01H3+hqxE3ilSpUAKsX/wDiB46SkOEQ6yPdh+6trf6iPlWzO1gTXNnO/ERiOOTOdUw628u6Cx/1E0AUzmN/1iQJtEoX/Gdz86+RYxopbJbuKU1W4/fOoPW49Ki4WXNM8ra5cz+vT7SKuPLvIAlCs+IEZIB925udSDci9TySjFfMPCLk9Fn4Xypi8XHFiFxBYZSquTZgtz3fcuLXb5mpvEuGcQjRDIWkVc2ZxbMthZe8oDHbc23PpC4jyJPh+yZMVfDhgrfRABNzotxrt8ba1Lk5ixWHw8RUt38QVJkF1MDZgvdb3bZdeuprnXF+S7TrwQeH4pjJmlJLMCo7TUpYNow8O6ba9SKuPLK/2ob6gjU3HuA6f14ULwvNCSkjEYWPXM/aI+tgSAxBHW1xqd/Oqpxbj80cinD50EZuZFN7gAXOo90WN/jbpWxVeSUtGwcRVYUDMGIJC2UAm5uepAtYHrQrnXliKaKLtAbLKuzFe6Qc23Tb+VBuHc4/puDSOVgcRnvlAjuyhZNRnGQ20v1HTWjfFON9vxCLCxXOVZA5IsA+Um3eFyQFGouO9Vq5LRu0rLBBhookjAZVTuomuh07oBqDzU7xhMhUaMbsuaxFrFe8CD86g8Y4ZJJB3GASGW7gA3LJlBBvfZdb61H4nzGuLz5CpVM2XKbkqRcFhfSlaQRtsqPFMQe2gIBXSMk9DmmjJOnjWscYxavhpCjA2OU2/jUEfbWO8VLfqyc2kcNv80ZsPvq14TiZkjbKWAzXYG/U3H4fI0s210PGKk+y38tSq2EXUdwENe2mpNz5WNBBhx/002+sAt4bX+6qpwPiBjxc4uTmhZbX3Pd/nX1eeY04kkmUlVVIyb9QApt3rbXG2/zrVFCO0T+JyEcWA1/aD7Cfyq5RDOuHe1i4J9GiLEfMD5VWeKYaH9J7cyNmL5lIHdyWZ+u7FSLdKMYLiIEWEKnNkj73jmKKoB8NGNVSsRsfwuHvicSvgIvtQ1V+UeIlf0iBw8ixEt23XUqqpa+pJUkW6D1qyjGGLGYohcw/s4vsALNcknTQfh41WeS8XG+I4grG+YxWVt2UZhcjxJO3gR0p0lwkiLb+JH+Y1jeMG9oUXQOO6O0I7qg3PuAhQBa5OtV7jWMmkiUyZcuqoXkFg1/dAUHW/SiKRtI8Xet+sBsP3cLe1thfL9lV6bDxHBIDmsGxJa/992bsMviLhPW9ccY+TubK1zDw4lHFu8pJ9RoRQrl7izQtHMvvYaRXHmhNmFW/jEdsTOp/vG+0A2+RqjQRZMS0Z2Ysh+DbfhXWnaOVqmdicLxYlhR1NwyqQfIgGpdUD2K8UMvC41Y96ImI/wCAkD/Tar/WmEfHvaJz4Kfurk+XFEx4ycm5kcgHyZj+FdQ814jJhJm8I3PyU1ypiu7w8fvSfcKAB2BUCMk/SdF9Bdj91aHgiGjBU67etUzgOC7Ts08e3b5Jb8TTUHFZYsy32NvUX/CoZI8nR1YJKKtmqcvcUMzHCTKJEk0Ia9vQ9KuT8pwCJBLJdImbK7EXGawCknQ9d/Gs35P4vleN220uRuL1pfHHkjdWhDTRYoZGUKGySBbpLqNRoAQd7CxvXPFKMnZXLeqIrcl4OQELNH6ZdPk1RD7LlJzDEKSdxsCDfrr18aq2PYo+Hw7IT28ktiW1vGVQgnLmsfC5qXgcC0y4l8mQxyJGRcjaUJmTLawJ1uLGqvj5RNxk3t/gMcxcM/R8OkMoSRBdo8qrm7oAN2ABG4PpVZ5CxskmMknJIyjU3JP6xwu5JOgqxcwcOkiglu18pkF2ubjtYU0u3Ua28/HWgvJr4ePDzx5srvquYi5KiwVSLa2zE/w08Z+BZaVGq8JxnbwSoDaRLhvO4uL/ABGl6qHCuXhAZF7RArKLFmtrr4joCB8RUjg3GBh+IMpPcnCnU3GncPw0Cn50XxMbRSN2ZBuLobAizXsRe+x+407WiSdMo3EMBlYDOHyqE300Ua207p0638ql2KyixuoCZtdLmNQOp+dzUrmTizPOiM6syA5it9GLE2ORTrly/OhXFeKFpL2H6qSNb20sV3YhRfvMdSAayXVMZNXY0sBGMYAgnKTqQNMl7fE3sPOiPAIo8EjT4rCtJK8rJ31vkBUPsdLtcedq84EMeIo2VjGRCb5TY92M2vt4fMU/guIMxKOpIMrEanKtgCTbqe8QDvS2Y3Z74oysFkjjZE+itjooVkW/hqp+NqG8J4uiRSBjZyzIqi9yxCKrAbC1r3PWjDcOmmQmKJ47sNcxUMv1tTYjytTGH5EkNmmlXOvu5QSAegJbcbdKZSS7BRlLpFckxbN2hxH66Q73xEoykd0DuDKzADfMRa29ROWWVMZDmsLO1ix3BU6E2Pj4dKO8V5KxNz2bxsCSdSVOpJ8D40M4dyzi48TCXjsokBLBlZQttzrcfKs+JaZqxyT2g/JxaNG7qodG1DkaMign3Ray2+dqhy8TQmOyICgIAudRe99tNyLio3F+HuoG/vC5HgVUHr5VUOK46RcNIwYhkkYXB6bgfCuSHzHRJUE+Y5VurLltmO3mevw29Ko3MseTEBh1CmjXH8a/6SUucuRzlvcaEm/xvQvmsXELeKmu3H9JyZPqNc9g2O/WYqHpnSQf+Iv5qa2asA9hM/8A1i4+vhUb/KwX8a3+qCFf57H9gn/7qT/Y1cv8WFsFF/GfurqvmfD58LKvijj/AEmuWeLp/Yl8noAI+ziMNi8Mp1DLOPmLUN5o4f2GLkRxbMcwPhbT86kciYnJisI17frJFP8AiUGrr7X+UWKDFxjMik57bqGNwT5Zr6/vVzSlWVJ+UdEPoYB4JkEQ717DfqatHBedeyMUcmfsy6jMD7pJA1129ay7AYzKOt/srV+TuW4cVw2V3VXlcsqFybAgdLEZT4HxtU5xSezp5px0febJOz4lhOvZyYobeLQG/n73nRbBOwXHgCwGRx017bN8elBeLmaZcLO62bBCaLEi4DhwYQrBfea6gHS9t9qmYgYlpcVHCFJxGHWdCAS2UyEqhBIsxBzE3tpprRxb6EUku/8AeiTzTOzwzgd4kzAKBuwxGGPmT1OnQGqBhsayRkEZWzBs2t7kWIFztoCfjVxxckOFY4md/wBJl1ZI81kBdbMNTcnMPoaX66aVHEfr27SMCOy5jHrl2YnUkkjTz3rarZLJtpFgfGyYoxHLZ4SfpAA7ePw6X+FWGPmadVRGw+itlV86m+Y3CW3tvqahYTnNJsLIhjCyxKMzZVAbL9LTbbUU3jOYk/QoyjLmGJhYjrpmv/XlSLJkbonJKuzxx/irGQsYo1yNDdge9ZnFrWtcaW11q6cD5USXDymT3piSdSRtlBNzfpf0qjSH9Mx80ZUlWEFjqAAgVr6b3Jt861DCQ5Y8hYg30IGm2gB9d/IVSMW5U30ItmWnjE+DYQyg9yRQrbWCBcygjUhsqeg+NFDzFAjrlbqfe2uywrrbwNz86f8AaHwQFWmC6xq5A88pGumviPMVncPA8Q0sMaxM7yWlyqCW7M5LNa2wANEfT8GbRqMUU6RxyRylQ6I1n90swDEa6XN+tjbY6Um5qaMkYiIrb6S/ZofLXe/gDRNcUU/RcKyWLYVnIO4MYiTKRb940zxHCZAbAMgDHIwuuiM3dPvJ7o90j4Gm42Xjka6HMNxGKUkI4LDddmB81NiPlTOOx8cfvuq6E6nWw8hrVem4ZFKSVPYuCbK3u5gZE7rWy+9G9r5WOXSgPEuETCQhiC2u4a5I2+nrWcCvx3Qdx/OcQuI1Lm3wHl52qu8R4m2IUho4ghOxRTt1NwdfwpluHS3IDC+mmXXz0zUy2Elto62F72C6eHXSqKKROWSUvII47gfemJuwDDpbUHoKCcxn9Rh/gaN8ejdYGLOCLAaBfe8LigXMptHh1/cv8zVIkJF+9hH/AGkP/wBM/wDmpXQ1YD7B8P8A29z9TDRr/mbN/wCmt+phRjHJeNh4qfurlzj2CKxzx9Udvsb8q6pZbi1YD7Q+F9njphbuyAN8xY/aKAMw4ZPlTNe3ZyI3odDW3cs80BY+znAkR1I11DAi1iDp4+VYbgorSPEfpBl9RqPtFXrlufPhlN9RoR1uNL/ZXPnjaTOr+HadxZ75g5FgjlLRGQRsbquhy/u36gdL9KL8C5lOGw/YrGroGzC7EG9rHbyqTJjhJA8bDvjUaaaHe/TSq9JC3pUbbXzHSoJdB+Tjk08maJF7WQohQe64RXcMxa5DhVIz3Gm+lW/EY1mgWae8mHUAsI9JItR3JIzbPlOl+lZpgDldQSRmZ1BB1DPh5kUi377LWu8wYhI4I8RKBKuSMd0XZidb6m1tjZbEkamwp4rZHI+PRj/G+PdtNIxUFQuSMZbFVJPfF73JGpvtp4VJ4DwNTCZcR+rjbQDqygCwHiNx5W8Kb4jjFkxTuyKAxvYIFOXYGy+62W23W9LE4ntQEubKtk2so00sNfifOtk710crfllrk4HhF4ZiJYgE/VNt1bLoLnXc1XePlBw3CFBZnclyo0DLnUXsL3J1p5i68JnDmw0VbbsS6AnxygdfH1qTyNhZpwqrfKjk+N9QfXx9ai1x33s2W614Ldynwp8gdwGLLc5r20A6nTTwPjVmxc+VdQgY90lLbX006eOvw62qfw/AhFK2Fv63+2vUkYBGgFj4X1Nhe5+H2V0Yo8I0BW+IEyq1xl3JBSygb5tNfHpfb41RuAYgwcfjzkleycX1Nk7M233AIArWZsMLWsMut1I7t/HXrVK5swJDCVFykb26/D0APjS5Pk/5EjGiZi8T23MSRhrqmCfbYFmQ+uljRfjWHIVr/Vf/AMp6yrljjVuYUd9FKyKfIdgSD8Li/rWs4xJ3xoQoGwjQNdri4lzAW8dUOh8j41VfMrMiysYWNXNt8syhvI9tjG+5hVO5x4Sg41hFC9zJESvQm7XNvO1WXlSzYnHlGDoMYtiDfaOQ306aihvOI/67wv8A3afe9Ay2zOuE4MHE44nXLHireRVrAj0qJwnCg8NxZ+kGgsetiRcfbRngy/r+Iaf8vGf7jTsnA2wmDxkTlWNsK9xtZgPH1pgK5iYwMDhbAZnaS/ie8NfstTHNJvOqD6CIvrbWnOEt2smHQ+7CrMf8xY/ZaoQn7XFNIdszOfguv5UyEZtvsG4dripumdYx8I0/NjWx1RvY7wow8LizDvSXlPxkJb7iKvNaYKsz9r/Brokyj3SQ38LW/G3zrTKHcf4YuIw7xsL5lIoA5G47EUmEg66/4hvRzljGBMQV2WYZ1+P0hXrmng7K0kTDvKTb+Jd/mNarnD5SVyj9pGc6fitLJWqHhLjKzUWQBr9NvSoGJw9iddfC+tSuXuJLPCrDe2vxHSjY4GuJkVWIX969rDz8fhXG9dnp9q0VUYAywzEXzRr2iEbgqQfzqfytxSLGxdjj5prwG8ZUjVW6Nfex2P7xq7pyTg4rhcVKMy5Se4RY720vQKH2YYaGQvFxEAWIIeMHTfcMPAVvKNNWQn81adHnFcB4e7lmxmIzEWuYgdALAab2F9fOvDcqYN3HZYzLYAFXhbYX8xubfKnDyrB04jCfIxsP/VXiLkRpG/V4zDt6v8tqW/ub8OH3Cb+zWWQZxiYJAFsAUYKPAe81hv0qy8s8tDDrleNBbTKB3f4hawNz6155Y4FNhrrK6OGUglb7HxDAUV4ZjFljWzAvGQhuTY2vY3G+l+tLjqcqfg58kFHaJ+HxGY6mx8Mvhv01/nTk1tLbX8Ta/obGmMOyGxJIC3BuSNdPP4V5xOMXUC17jQ/P+ddzJIdxRGXVrePW332oZiHEqMrWbSwNhe9hqPhpU0yI6Gxtv5a/mNqhTe9pm3XXW2p6G/e1O1Y0mqZhlnFOCLhuIDEHMDqAO7lDFct9P3elX3g/H1WMXNkA7p3KEC+Rv3DbTw09BnMPDVkBa97+WunWqdNjmhhnQXv2bgW8CP6NefHJLHOmAd9jGKDRY9iQbzKSAOhj6AdN7VF4/M8uLXECF80eiaG1hffTXehHsK4yqTYmJzYSCIqelwWWx8L3Fvh5itfxOHD+R8fzr0kjE6MTw0EizTmPDSlnDI/vEWkAY6W7u9NcbmmSCXtopAjpGrl7juxiyAGw12+NadHwxMPI7hMrPfM1yc92Zrm5tux26VlvtG462LxKYSI3AILnz8PgBr8vCmcV4NsqmEfssLJKdGlORP4fpEelhXvlLgpxEscI3ncJ8Ix3nPyFqjcanEkqxRapHZF8z1b1Na57DOVg0j4sjuxjsovPrI4+LaehoFNnwGHEcaqBYBQLfAVIpUqAFSpUqAMk9sHKZt+kxDb3vwb8PWsN4jEUcSppc6jwYbiuxcfglljZHAIYEEGubPaDyk2BxDBgTBJsfDwPxH2igADwbi/YSCVNI5D3h9V/yNaDguN3Fww1rJheByrd6Nt/Aqeoo/wLirQMFzXRvcfy+r5GpThey+PK46LxjOJHoQaF4riZG4I8dfuotBEuIHfIa+zD3x5i3TyNNzcl94qxJ1tv8vs1qK4+To+LJ9Ir0nEiRa4F/P8AlTWB4m8bjvafxWt50d/4NA+sRUKXltQeulM+Jiys1HgfHCcOpzXMTKd9SjHKy/DUH0o/hMNHmbs7BcxIytprYlrHr8Kyrg0E5BjVssTWDkqL2BDZR8bVoSMYIlCOjgjbKAbelRxtQbtizjz6QXllBBD+ZB1y2vpbxO2mtfERiQCFsQSW8TvtfTS/zqvtjzI652ygeH9b0WXFQ5TqxUC9tbDXQ+PTpVY5YyeiUsTj2SXwTXBbKFvcC9jexF7/AAJ8N6+NgCQ21tLbXOmug9K8txZFsWsbgDXwJ19aa4hxCMJ3GINtPIba220v8qopExhsMZWIJYa+diLEXsPPp0rPecZsPCbOBOxbLkjly73BvZTt8evlV15ixBXh5ZWCuygMUZgQD4AncjTa41rLuL8OMUWWO5zsly1rqcsnj0GepTULUmhdhvkHDYSB5BLFHhs4jKZ5ixcXJALEhdLbAW8b6UF5n5oxsQ7SKclXcBUZFIAsSADbawPjfxoomDwuIllE6OUQBk7+VQLa7dNdOmgvQnn7C4bCQqiTGQEqyRt76jK4Nz1Gw+dUjNyScTAFxLnbHBAWxC2kAOQKLkkeJubC9txQcscNCWY/2iceqodyfNq84OEIoxGIGg0ijP0iNj/CPtqEuaeRpJLkX1tuSdkUeJ2tVwCHKvAXxE0caftJjlU/VT6ch+AuB511dy3wRMJho4YxZUUKPTqfPr61SvZJyGcLF+kTqBPKB3f7tB7sY+8+fwrSaAFSpUqAFSpUqAFQTmvleLGwNHIL3Gh6g9CKN18Zrb0Acm80csyYKY4bEjuEkxSdB/Ly6UCSRoSUkGZD/QZTXTvOuGwGMiaHEOl+mozK3iPA1hGO5KmjlMGZJo7XicN3jrbKo3LfujfpegD1wLj7w2sc6HY/gfA/ZWlYHjvbCOQLZFGWRiRcHJoqi/eOnppWTwcqTROAs8Nmyk3LZQjYhsPmbubB1N7XNjex1saw/BpkTMXjWxsVzNdTnMY+j1NiNT3WBqE8UZbL48kodGow8XvqpyC+wH3/AM6mFoMRZZgt/ouBZgfA295fj51nMUs6MUZoiVUsTdhZVBYk2Xoqkm/QXr1jeMNFqcjBrFWRjlIuAcrKQD7wvfUda55YpWPyVGkvgAndsBbTpTUkAtuKrHMmMmiVChOYyxpcs5WzKbmxsRsLfK+lEOGuwkRMRlYSAqrI0i/rOgN2O4vrsTYdalL+HknTaLxzJxuifh0sxH86I4PB5m7pG+oNtienn5VUeNcWeKaKOCNAHDAyM8hOYEgAC4HQnrrRTFcwyQRLDEoxGIIGY7AE/Sb1vpR8KcJqnsx5Yzi7DvFEWCE5yN2JY2Gm+g16VVjjpMQjTRrEIFbJ2uYgsy290HRiLkG3gaF8XR2SVuIWl7NFawkcFnZlRY7XABZr200vXzCTSooWZo1EaraJCQqgjMQL9dRV80XCLkzjTXRHx3NeWU4fESukVwQwUMouLXIFiBqRufhTRiyBkZg8R1WUG8baX0bYG1jY671WuZeN4VpGucwK2spubhs333oHhJsVIjJEzRQG98zWUD4n52FasXxMaT0xL2GcXzeIYpYlGd5FMY1+gb31G386CPCE/X4w5nP7OHy6XH0VHhTRxsOG0h/Wy/3rDuj+AH7zUOPDPK2eUscx0G7ufBR+NdMIKCpGCmlfEuXkNlG56KOiqPuFbP7KPZiSUxWJTKq6wxNuP/yv++eg6U17N/ZugZJ8YAMtjHANVQ/Wf6z/AHfds0WKjAsCBTgSVWwsK+15EgPWvVACpUqVACpE0qGY+VqAJkuNRdzVV5m5gukuX9nFGzvY2JNmIW4NxfK2vlTWPlbWqxiMRZpY5NEnTLfzAcWv5q7eoFcn8bKccEnDv7evP4K4UnNJkDA4hJIEkmZmdgH7ruijN3soSNgoAvbahkCGfHRxuxaOUFGGxNhMwN1IN8uRbm9+94ih5ilhURyKe4MqsASrAaAggb2GoOoNO8uu68Rw+ZWW3aPqCDlEMvesdQNDqd6TKsTxOeOrp0130Ui8inxl76YzwWOObHvhplOXPKsR7WYkSIzst7yG5N5DfTUnq1V/DvN+m9gZHRlkKvGZJOyyi+Zrh7hQoLk32F6WPxEiYqSRLhlnaRT+8JMyn5gUb52xMRvjIyM+MhVALagG3asL+6co7Lx7xHjUlyhOO21ONdvUl/df+DP5k/s/we+XsWMR+mOUdVghaaG8subulimY9obnQHS2tQ+VJUxcOLeWMM2HhMiXZ7A62X3/AHRYafbTfs9zrDjx3rNhygvcjM2bQeZHSnOQmK4fiIMZRjh1S1jqWz6W3ufDyqWa4/FSb1xrb/mbC3x0t34CvNGJkbCRSO13WVG93Le4bcAnTSw1Gg9T949jZMOcIIs3fiilY5mLAgqe6Se6B4CpnO2BccMAYAEGG1s1yWGQLt71yPDRT6g+foZpGwaQhzIsESWW981l7vxudq6szTy40nq3f9BMfJQl/vkt2GwcmORMRM0IS7vcIwMaLIcwZhIoV9L7Eag7XqsQc7tDNK2Fw2eMnukk3NrjOSb7726CjHDeGSdnHw5Gd1bNNi5tcraLeGNrWI0UWvqAT9KwrXFeW5YseIrsILPM6pc2w6ZjqLaZspUDqdOouuGa5vLelpbe/b/t9t+QmnXBrf6fgLccmnxHDzOGAlimjknQG6qGS8V7nXKr3PgWYWuKD4HEriMRBDOEkaVo0lYu+ZnZipyhGC2C5BqPGiPJ3HInxUqGOUHGqwkDyq4uczDurCp1Jy3J0DeVAOX+C9hxfDqcxy4hctlNioYENfa1rfCpqc25wyN39S37XWvT/YakkpRS9M88cbDYbGYiDsI1EfaKj98tmyXS92y+8QDptRTimFR+HYOVYVMmJd492sCGdVyAtYE2XU0E5zxB/wCkMQwjBLvcMwJ0KrsNjVknxbx8O4YzqxMM5lYZdcvaym9um2npWPkseGVu3V7e/lf7m/8Aaapavx9wLxvhUWCxH6MkSTSIFMskmYrnYBssagiygEam5PlRrBYKP9FfGwoI5YWCSqLlbG1mTMbqNdRfoai894VmxbYmPvwzBWV11GwFieh23+8GzuGxRw3DJ0cESYt1EaH3uzW15CDqFN2t42BGlCnKeHHki3ybje/f1Kv6/pRjXGbi1rf+C3YPiMnZCaBizRJEZ4b3NpYY5Q6Dce81h1CnqKg4vmmVyWik3fDKp3yiUzBjvY+4tvWgOExk2HxwkjuGEGEBU3AZP0aAMh08vQgHpRTi+FhymaC6iefDXjt7ro0xfyHvi48dRoayE543GE23GTVP073F/mvto1pSuSW0tr9zVOHcXuo1vpRfD8RNZ/wlXsKtvDo2I1r1jjLFFir1IBodh4jU9RpQB6ry8YO4r1SoAgYjg6N5UIx3KCuCNCDVmpUAZpivZoQSUaVL6WSRwLeAs2npQWf2YZb5QwJ3ILAm3ib3PrWy0qVQivA3J+zB8R7PXHRj8ST99C8TyJJpobC9t9Lm5t4a610SYlO4Hyrw2CQ7qPlW0jLObG5TnQWUuovewJAvprp8B8qiScCxANzIwAa7FpMu+5OZhmJA8zpXTLcJiO6LUHG8nYSW3aQo1tris4r0HJ+zE+ZcCjjLhWiDGRGVxLlK2Lb5iAv0Df7rCqkeBYgMQXbMp17waxtfcXB0Pj1ro0+zrh//ANunyFSIeS8IossQA8qOK9G8n7OccFgcRFLHIxeVUZWMbE5WAOqm1tCLirJzi0aoqYaMJLMQ2dJCSsQs66D3SQyG4INriwubbYeUMN9So0PIeDVywiAJ3P8AQo4R9Byfs5yg5enBLKzhmFmIJBI0NiRvqAalJwLE/wB5Ltb3m2ve2+17G1dIDlTDf3de15aw4/5Yo4r0Zyfs5xPKsz2zl2ttmJNvhfapycpTte7ykHcF2sfIi+tdCrwKAf8ALWnV4ZENkX5UcV6DkzBcByVMvuNKn8Dsuvj3SKJYT2cMTmKsWO7Ekt8bnWtuXDKNlHyr2FHhRxV3QWzKeHezMg3IYnX3mJtfe2Ym17CjcHs2jzBmGoN9za/jbYn41fKVbSC2B8Jy6iURjwiin6VaYfAK+0qVAH//2Q==)![](data:image/jpg;base64,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)


# 游戏开发


自打DHTML出来后，开发者就开始在web上弄一些好玩的东西，早在1999年，就有人开始用DHTML做网页游戏，比如：[Fun and Games with DHTML](http://www.downes.ca/post/276) 。可惜限于当时浏览器的性能和特性，加上CPU处理能力有限，许多还是停留在设想中，但这并不能挡住开发者前进的脚步，他们并没有 Give Up。随着浏览器性能的改进以及HTML语言本身的发展，加上硬件性能也有了长足的进步，现在如今诸多的 Javascript Game Engines 已经如雨后春笋般的冒出来了。

相较于HTML4，HTML5做了像素控制机制以及图形加速方面的改进，正是这些改进，让WEB游戏开发变得简单，那么，接下来，在本文的上半篇，我们首先要介绍的是两个2D HTML5游戏引擎，下篇我们会介绍一些好玩的3D HTML5游戏引擎。



## 一、GameJS 开源2D HTML5 游戏引擎


[GameJS](http://gamejs.org/) 的前身是从Python界著名的开源 [PyGame ](http://www.pygame.org/)游戏引擎移植而来。如果你熟悉PyGame的开发，那么对于 [GameJS](http://gamejs.org/) 应该可以很快上手。[GameJS](http://gamejs.org/) 可以和服务端的[RingoJS](http://ringojs.org/)集成使用，而[RingoJS](http://ringojs.org/)是用Java写的js运行环境，所以你需要Java 1.5以上版本，同时还svfd安装Ant。下载代码仓库还需要用到[GIT](http://git-scm.com/download).


### 开始玩![](data:image/jpg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAkGBggGBQkIBwgKCQkKDRYODQwMDRoTFBAWHxwhIB8cHh4jJzIqIyUvJR4eKzssLzM1ODg4ISo9QTw2QTI3ODUBCQoKDQsNGQ4OGTUkHiQ1NTU1NTU1NTU1NTU1NTU1NTU1NTU1NTU1NTU1NTU1NTU1NTU0NTU1NTU1NSk1NTUtNf/AABEIACAAIAMBIgACEQEDEQH/xAAXAAEBAQEAAAAAAAAAAAAAAAAGBwUD/8QALRAAAgIABQMBBgcAAAAAAAAAAQIDBAAFERIhBiIxB0FRYZKhwRMUQkNxgZH/xAAWAQEBAQAAAAAAAAAAAAAAAAADBAH/xAAdEQACAgMBAQEAAAAAAAAAAAABAgADERIhQfAE/9oADAMBAAIRAxEAPwC44N9a5maVWCAlkin3GVlPJUaDb/ZYf5p4OEmBXqM6LNlKv4eRh9UH3wlS7uFEO1tULTV6YzCpds2Vo7tkccYkXaQA/dz/ACRp8owgwe6Kiljyu20qbFe5IYju13KAF1+HKkafDCHGOMMRNrOyAzjbtwUasli1IsUMY1Zm9mCfVFiXN46jQUysMU4b8wy7pF5P7eh7GGh11B400GMj1ezWzlk+VNar2TkQEj2Z68ZcRS6oqF+O0dzAd3JY8doxhVOv8qlKMud1Gj/V+Ixjbx7mAw9dQKbhujyR3fp0tFTISp9xzsoOX5y+W1gk1JzTWRgJ49d3LaljGQCF5Pgk8eMI0dZY1eNg6MNVZTqCPeMRqz6hZUJBXr5ibc0zBIoKqtK7seAFCjyT4w79OY84TJLDZtUko13sF6NaZVEqRMoYl9p4JcsdpG5Trr7ABYDGc9lKkqwUDmPhP//Z)


首先从版本仓库中取回GameJS, 进入gamejs目录:

```bash
git clone git://github.com/oberhamsi/gamejs.git
cd gamejs
```

接着获取编译所需要的依赖项:

```bash
git submodule init
git submodule update
```

编译 RingoJs:

```bash
ant -f ./server/ringojs/build.xml jar
```

OK, 现在可以启动GameJS的Web Server了：

```bash
gjs-server.sh   (如果是 windows环境用： gjs-server.cmd)
```

然后你可以在浏览器中访问 [http://localhost:8080/](http://localhost:8080/) 了。你应该在页面上可以看到游戏例子的链接，这些例子的源代码在GameJS的examples目录下面。  你也可以本地部署你的HTML5游戏(去掉服务端支持)：

```bash
gjs-statify.sh <app> <output-directory>
```

例如，部署GameJS的一个例子程序：

```bash
gjs-statify.sh example-draw /var/www/games/foo
```

供参考学习的一个很小的GameJS游戏代码，点击会变颜色的脉动的圆：  [![](./pulse-circle.png)](http://gamejs.org/apps/minimal/)

```js
// 一个非常小的 GameJS 应用用于展示GameJS的编程概念
//
// 一个脉动的彩色圆，单击改变颜色
//
// Play: <http://gamejs.org/apps/minimal/>

var gamejs = require('gamejs');

var SCREEN_WIDTH = 400;
var SCREEN_HEIGHT = 400;

// ball 是一个带颜色的圆.
// ball 的颜色可以按照一个色彩列表(Ball.COLORS)进行变化. ball.color 是色彩列表的索引号
// ball constantly pulsates in size.
function Ball(center) {
   this.center = center;
   //设置圆每秒增长的半径大小
   this.growPerSec = Ball.GROW_PER_SEC;
   //圆的半径
   this.radius = this.growPerSec * 2;
   //圆的当前颜色在色彩列表的索引号
   this.color = 0;
   return this;
};
Ball.MAX_SIZE = 200;
Ball.GROW_PER_SEC = 50;
Ball.COLORS = ['#ff0000', '#00ff00', '#0000cc'];
Ball.prototype.nextColor = function() {
   this.color += 1;
   if (this.color > Ball.COLORS.length) {
      this.color = 0;
   }
};
Ball.prototype.draw = function(display) {
   var rgbColor = Ball.COLORS[this.color];
   var lineWidth = 0; // 线宽为零将以指定的颜色填充该圆
   gamejs.draw.circle(display, rgbColor, this.center, this.radius, lineWidth);
};
Ball.prototype.update = function(msDuration) {
   this.radius += this.growPerSec * (msDuration / 1000);
   if (this.radius > Ball.MAX_SIZE || this.radius < Math.abs(this.growPerSec)) {
      this.radius = this.radius > Ball.MAX_SIZE ? Ball.MAX_SIZE : Math.abs(this.growPerSec);
      this.growPerSec = -this.growPerSec;
   }
};

function main() {

   // 当鼠标UP事件发生的时候，圆改变颜色
   function handleEvent(event) {
      switch(event.type) {
         case gamejs.event.MOUSE_UP:
            ball.nextColor();
            break;
      };
   };

   // handle events.
   // update models.
   // clear screen.
   // draw screen.
   // called ~ 30 times per second by fps.callback
   // msDuration = actual time in milliseconds since last call
   function gameTick(msDuration) {
      gamejs.event.get().forEach(function(event) {
         handleEvent(event);
      });
      ball.update(msDuration);
      display.clear();
      ball.draw(display);
   };

   // setup screen and ball.
   // ball in screen center.
   // start game loop.
   var display = gamejs.display.setMode([SCREEN_WIDTH, SCREEN_HEIGHT]);
   var ballCenter = [SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2];
   var ball = new Ball(ballCenter);
   //安装FPS回调: gameTick ，帧速：30fps
   gamejs.time.fpsCallback(gameTick, this, 30);
};

// call main after all resources have finished loading
gamejs.ready(main);
```

GameJS的文档在：http://docs.gamejs.org/， 另外 PyGame 的[教程](http://pygame.org/wiki/tutorials)和[文档](http://www.pygame.org/docs/)你也可以参考.


## 二、轻量级短小精悍的CraftyJS 2D JS游戏引擎


[CraftyJS](http://craftyjs.com/) 压缩处理（Minified+GZIP）后代码只有10k左右。虽然精悍但是也包含了动画，事件管理，区域重绘，冲突检测，精灵等组件。


### 开玩![](data:image/jpg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAkGBggGBQkIBwgKCQkKDRYODQwMDRoTFBAWHxwhIB8cHh4jJzIqIyUvJR4eKzssLzM1ODg4ISo9QTw2QTI3ODUBCQoKDQsNGQ4OGTUkHiQ1NTU1NTU1NTU1NTU1NTU1NTU1NTU1NTU1NTU1NTU1NTU1NTU0NTU1NTU1NSk1NTUtNf/AABEIACAAIAMBIgACEQEDEQH/xAAXAAEBAQEAAAAAAAAAAAAAAAAGBwUD/8QALRAAAgIABQMBBgcAAAAAAAAAAQIDBAAFERIhBiIxB0FRYZKhwRMUQkNxgZH/xAAWAQEBAQAAAAAAAAAAAAAAAAADBAH/xAAdEQACAgMBAQEAAAAAAAAAAAABAgADERIhQfAE/9oADAMBAAIRAxEAPwC44N9a5maVWCAlkin3GVlPJUaDb/ZYf5p4OEmBXqM6LNlKv4eRh9UH3wlS7uFEO1tULTV6YzCpds2Vo7tkccYkXaQA/dz/ACRp8owgwe6Kiljyu20qbFe5IYju13KAF1+HKkafDCHGOMMRNrOyAzjbtwUasli1IsUMY1Zm9mCfVFiXN46jQUysMU4b8wy7pF5P7eh7GGh11B400GMj1ezWzlk+VNar2TkQEj2Z68ZcRS6oqF+O0dzAd3JY8doxhVOv8qlKMud1Gj/V+Ixjbx7mAw9dQKbhujyR3fp0tFTISp9xzsoOX5y+W1gk1JzTWRgJ49d3LaljGQCF5Pgk8eMI0dZY1eNg6MNVZTqCPeMRqz6hZUJBXr5ibc0zBIoKqtK7seAFCjyT4w79OY84TJLDZtUko13sF6NaZVEqRMoYl9p4JcsdpG5Trr7ABYDGc9lKkqwUDmPhP//Z)


这个很简单，从[CraftyJS](http://craftyjs.com/) 下载 crafty.js文件。  它的游戏对象分为实体(Entity)和组件(Component):

```js
var player = Crafty.e();
player.addComponent("2D, gravity");
```

上面的代码就建立一个 player 实体，并在player实体上添加了两个组件(2D 和 gravirty).  OK，这里就解释下它主页上的最小代码的例子，你可以在它的主页上运行这个例子，运行这个例子你可以看到一个铅笔掉了下来，你可以用左右光标键去控制这只笔移动，按上则是跳跃：

```js
//初始化 Crafty 游戏，指定FPS为50,宽度为580, 高度为225
Crafty.init(50, 580, 225);

//创建player(铅笔)实体,这个铅笔是2D，挂在DOM上的，受重力（gravity）影响的,
//可以左右移动(twoway)的图像(image)
//设置它的x位置在Crafty.viewport.width / 2, 宽度和高度都是16
//重力方向是落向floor实体(该实体是在后面创建的)
//设置twoway参数: 有三个控制键，左键，右键，上键
//设置图像元素
var player = Crafty.e("2D, DOM, gravity, controls, twoway, image")
  .attr({x: Crafty.viewport.width / 2, w: 16, h: 16})
  .gravity("floor")
  .twoway(2)
  .image("favicon.png", "no-repeat");

//创建不可见的 floor 实体
var floor = Crafty.e("2D, floor")
  .attr({x:0, y: 225, w: 580, h: 5});
```

可以去玩玩它的sample应用：[Demos](https://github.com/craftyjs/demos)

或者去学习下他的教程：[Tutorials](http://cykod.github.io/Presentations/HTML5/Crafty)。当然你也可以去看看他的开发文档：[API 文档](http://craftyjs.com/api/)

随着OpenGL/ES WebGL的标准正式确立，如今Web 3D 游戏开发的序幕也被揭开了:

* [Firefox/4.0b8+](http://www.mozilla.com/en-US/firefox/all-beta.html) 以上的版本以及 [Firefox Nighting Building](http://nightly.mozilla.org/) 已经默认支持WebGL
* Safari： WebGL is supported on Mac OS X 10.6 in the [WebKit nightly builds](http://nightly.webkit.org/).
* Chrome/Chromium： WebGL is available in [the stable release of Chrome](http://www.google.com/chrome/).  BTW: [Android上web 浏览器 已经支持WebGL](http://blogs.sonyericsson.com/developerworld/2011/02/24/webgl-support-in-the-android-web-browser/)了
* Opera： WebGL is supported on Windows in [the Opera 11 preview build](http://my.opera.com/core/blog/2011/02/28/webgl-and-hardware-acceleration-2)


接上随着WebGL（OpenGL ES2.0）标准规范在2011 GDC（游戏开发者大会）上正式发布，支持WebGL的浏览器可以不借助任何插件便可提供硬件图形加速从而提供高质量的3D体验。Web 3D 游戏开发的序幕也被揭开了，WebGL目前是唯一能在各个浏览器中充分利用GPU硬件加速的形式，这更利于HTML5的游戏开发以及各种更酷的直接呈现，不过这仍然算是较新的技术，目前不是所有的浏览器都支持，请留意你的使用的浏览器和版本：


* [Firefox/4.0b8+](http://www.mozilla.com/en-US/firefox/all-beta.html) 以上的版本以及 [Firefox Nighting Building](http://nightly.mozilla.org/) 已经默认支持WebGL
* Safari： WebGL is supported on Mac OS X 10.6 in the [WebKit nightly builds](http://nightly.webkit.org/).
* Chrome/Chromium： WebGL is available in [the stable release of Chrome](http://www.google.com/chrome/). BTW:[Android上web 浏览器 已经支持WebGL](http://blogs.sonyericsson.com/developerworld/2011/02/24/webgl-support-in-the-android-web-browser/)了
* Opera： WebGL is supported on Windows in [the Opera 11 preview build](http://my.opera.com/core/blog/2011/02/28/webgl-and-hardware-acceleration-2)


需要注意的是，虽然Chrome已经完全支持WebGL，但是如果你还在XP下使用，那么有可能你的显卡（GPU）是在黑名单中，是没有打开WebGL的，你需要手工执行命令，以忽略GPU黑名单：

```bash
chrome.exe --ignore-gpu-blacklist
```



## GammaJS 最简单的WebGL下开发游戏的开源框架

站点：[http://gamma.delfick.com/](http://gamma.delfick.com/)

GammaJS 以极其简单的开发体验给我留下了深刻印象。他能快速的帮助我们利用WebGL搭建2.5D游戏。

下载：[gma-min.js](https://github.com/downloads/Royce/GammaJS/gma-min.js)

```bash
wget https://github.com/downloads/Royce/GammaJS/gma-min.js
```

使用:

**最基本的架子：**

Game.html

```html
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>

    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <title>My Awesome Game</title>

    <!--
        Include any style sheets here
        <link rel="stylesheet" type="text/css" href="gamma.css" media="all"/>
    -->

    <!-- Include the Gamma Library -->
    <script type="text/javascript" src="gma-min.js"></script>

</head>

<body>

    <!-- The element to contain the rendering canvas is called #gamma by default -->
    <div id="gamma"></div>

    <!-- This javascript file contains the game specification -->
    <script type="text/javascript" src="game.js"></script>

</body>
</html>
```

game.js:

```js
require(['gma/base', 'gma/manager'],
    function(gma) {
        // The game specification is contained within this function.
        var manager = gma.manager();
        manager.storeLevels({});
        manager.init();
    }
);
```

在 game.js 我们需要用 require 函数来导入GammaJS 功能库的部分（gma/base, gma/manager），当需要的功能库都被加载后，匿名初始化函数function(gma)就会被执行。在初始化函数中，我们要创建一个gma.manager，它默认会维护一个canvas在id“gamma”的div标签中。

和以前一样，我们先来做一个最简单的“游戏”：

game.js:

```js
require(['gma/base', 'gma/manager'],
    function(gma) {
        // 设置该画布的大小是600x500,可以设置 containerID 来改变默认的div id名称.
        var manager = gma.manager({
           width: 600,
           height: 500
        });
        manager.storeLevels({});
        manager.init();
    }
);
```

要让游戏跑起来，我们需要初始化游戏设置，比如 level 信息，manager.storeLevels用来存放游戏的level，然后manager.init。

OK，我们首先配置游戏的一个 Level，首先 Level 里面要有游戏角色站立、行走、跳跃的台子(platform)：

```js
var myLevel = {
    entities : [
        {type: 'platform', top:0, left:0, width:30, height:3},
        {type: 'platform', top:0, left:36, width:30, height:3}
    ]
};
```

platform是默认实体（entities）类型，所以如果实体是台子(platform)则类型可以省略:

```js
var myLevel = {
    entities : [
        {top:0, left:0, width:30, height:3},
        {top:0, left:36, width:30, height:3}
    ]
};
```

好了，现在我们使用 storeLevels 将 myLevel 加进来。

```js
manager.storeLevels(myLevel);
```

现在我们的game.js 像这样：

```js
require(['gma/base', 'gma/manager'],
    function(gma) {
        var manager = gma.manager({
            width : 600,
            height : 500
        });
        var myLevel = {
            entities : [
                {top:0, left:0, width:30, height:3},
                {top:0, left:36, width:30, height:3}
            ]
        };
        manager.storeLevels(myLevel);
        manager.init();
    }
);
```

接下来就轮到我们的主角上场了，首先我们需要在require中添加 gma/entities/character 库引入对角色的支持，然后我们就可以创建角色实例（规定它的位置和大小）:

```js
manager.character = gma.character({
    left     : 0,
    bottom   : 0,
    width    : 3,
    height   : 6,
    depth    : 3
});
```

接着我们要设置角色在level中的出生点位置(spawn)：

```js
var mylevel = {
    spawn : {
        main : [15, 24]
    }
}
```

注意，如果没有指定spawn main 的位置，那么默认spawn出生点是(0,0).

现在我们的game.js像这样子了：

```js
require([
    'gma/base',
    'gma/manager',
    'gma/entities/character',
    'gma/events'
],
    function(gma) {
        var manager = gma.manager({
            width : 600,
            height : 500
        });
        manager.character = gma.character({
            left     : 0,
            bottom   : 0,
            width    : 3,
            height   : 6,
            depth    : 3
        });

        var myLevel = {
            spawn : {
                main : [15, 24]
            },
            entities : [
                {top:0, left:0, width:30, height:3},
                {top:0, left:36, width:30, height:3}
            ]
        };
        manager.storeLevels(myLevel);
        manager.init();
    }
);
```


**控制角色移动：**

现在我们来学习如何来控制角色移动，我们希望按下左键角色向左移动，按下右键向右移动，按下空格键跳跃。
首先，我们需要知道这些键的ASCII码值，左键：37；右键：39；空格：32。

使得角色移动和跳的方法是：move和jump。我们需要使得当相应建被按下后相应的方法被调用即可。勾挂键盘事件的是方法是在keyHandler.register（我们需要 gma/events 库）上：

```js

gma.keyHandler.register(37, function (keyEvent) {
    manager.character.move(gma.constants.LEFT, keyEvent);
});

gma.keyHandler.register(39, function (keyEvent) {
    manager.character.move(gma.constants.RIGHT, keyEvent);
});

gma.keyHandler.register(32, manager.character.jump);

```


事实上，GammaJS提供了Curry函数来使得勾挂移动函数更为简单，下面f1是和f2等价的：

```js

f1 = function (keyEvent) {
    manager.character.move(gma.constants.LEFT, keyEvent);
};
f2 = manager.character.move.curry(gma.constants.LEFT);

```

因此上面的函数可以简单的写成：

```js
gma.keyHandler.register(37, manager.character.move.curry(gma.constants.LEFT));
gma.keyHandler.register(39, manager.character.move.curry(gma.constants.RIGHT));
gma.keyHandler.register(32, manager.character.jump);
```

现在我们game.js是这样的了:

```js

require([
    'gma/base',
    'gma/manager',
    'gma/entities/character',
    'gma/events'
],
    function(gma) {
        var manager = gma.manager({
            width : 600,
            height : 500
        });
        manager.character = gma.character({
            left     : 0,
            bottom   : 0,
            width    : 3,
            height   : 6,
            depth    : 3
        });

        var myLevel = {
            spawn : {
                main : [15, 24]
            },
            entities : [
                {top:0, left:0, width:30, height:3},
                {top:0, left:36, width:30, height:3}
            ]
        };
        manager.storeLevels(myLevel);

        gma.keyHandler.register(37, manager.character.move.curry(gma.constants.LEFT));
        gma.keyHandler.register(39, manager.character.move.curry(gma.constants.RIGHT));
        gma.keyHandler.register(32, manager.character.jump);

        manager.init();
    }
);
```


**创建一个敌人**

有了一个主要角色，自然得有敌人，这样游戏才会具有一定的趣味性。所以，现在我们来创建一些敌人吧，GammaJS支持如下的敌人实体（每一种敌人有自己的习惯）：

* gma.platformEnemy: 从台子上一端移动到另端
* gma.patrolEnemy: 在指定范围内巡视，需要制定巡视的范围：limitLeft和limitRight
* gma.jumpingEnemy: 指定的位置上跳动的敌人



```js

entities : [
    gma.platformEnemy({bottom:0, left:45, width:3, height:6}),
    gma.patrolEnemy({bottom:0, left:6, width:3, height:6, limitLeft: 3, limitRight:12}),
    gma.jumpingEnemy ({bottom:0, left:7,  width:1, height:2}),
    gma.jumpingEnemy ({bottom:3, left:8,  width:1, height:2}),
    gma.jumpingEnemy ({bottom:6, left:9,  width:1, height:2})
]
```

当许多敌人有相同的属性的时候，我们可以通过使用定制类型（addCustomDefinitions）来设置这些相同的属性，比如jumpingEnemy的宽度和高度都是1和2：

```js

manager.addCustomDefinitions({
    types : {
        jumpingJack: ['jumpingEnemy', {
            width    : 1,
            height   : 2
        }]
    }
});

```

定义自定类型后，我们就可以这样来使用：

```js

// Now we can reference jumping jack
entities : [
    gma.platformEnemy({bottom:0, left:45, width:3, height:6}),
    gma.patrolEnemy({bottom:0, left:6, width:3, height:6, limitLeft: 3, limitRight:12}),
    {type:'jumpingJack', bottom:0, left:21},
    {type:'jumpingJack', bottom:3, left:24},
    {type:'jumpingJack', bottom:6, left:27}
]

```


**材质模板**

默认下，所有的实体会被作为蓝色的方块渲染，这个是通过实体的template属性控制的，template的默认值是cube：

```js
manager.addCustomDefinitions({
    types: {
        jumpingJack: ['jumpingEnemy', {
            width    : 1,
            height   : 2
            template : 'cube'
        }]
    }
});

```


如果你希望定制实体的外观，你首先要在templates中创建自己的材质，下面是创建绿色的方块材质（greencube ）：

```js

manager.addCustomDefinitions({,
    templates : {
        greencube : ['meshTemplate', {
            mesh : gma.unitCubeInfo.mesh,
            material : {color : "#090"}   // Very Green
        }]
    }
});

```

现在我们将greencube 应用到jumpingJack上：

```js

manager.addCustomDefinitions({
    types : {
        jumpingJack: ['jumpingEnemy', {
            width    : 1,
            height   : 2
            template : 'greencube'
        }]
    }
});

```

**注意**：默认cube和 redcube已经在GammaJS中存在。

我们还可以给我们的方块加上贴图：

```js

manager.addCustomDefinitions({
    templates : {
        brickscube : ['meshTemplate', {
            mesh : gma.unitCubeInfo.mesh,
            material : {texture : 'bricks.jpg'}
        }]
    }
});

```


**注意**： bricks.jpg必须在和html文件同一文件夹中.

如果希望贴图重复，使用repeatX,repeatY属性：

```js

manager.addCustomDefinitions({
    templates : {
        brickscube : ['meshTemplate', {
            mesh : gma.unitCubeInfo.mesh,
            material : {
                texture : 'bricks.jpg',
                //This will make the bricks double the size
                repeatX : 0.5,
                repeatY : 0.5
            }
        }]
    }
});

```


OK，现在可以使用新的brickscube材质了：


```js

var myLevel = {
    //...,
    entities : [
        {template:'brickscube', top:0, left:0, width:30, height:3},
        {template:'brickscube', top:0, left:39, width:30, height:3},
        //...
        // Enemy specifications removed for clarity
    ]
};

```

现在我们的game.js变成这样了：

```js

require([
    'gma/base',
    'gma/manager',
    'gma/entities/character',
    'gma/events',
    'gma/entities/enemy'
],
    function(gma) {
        var manager = gma.manager({
            width : 600,
            height : 500
        });
        manager.character = gma.character({
            left     : 0,
            bottom   : 0,
            width    : 3,
            height   : 6,
            depth    : 3
        });
        manager.addCustomDefinitions({
            templates : {
                greencube : ['meshTemplate', {
                    mesh : gma.unitCubeInfo.mesh,
                    material : {color : "#090"}
                }],
                brickscube : ['meshTemplate', {
                    mesh : gma.unitCubeInfo.mesh,
                    texture : {
                        src:'bricks.jpg',
                        repeatX:0.5,
                        repeatY:0.5
                    }
                }]
            },

            types : {
                jumpingJack: ['jumpingEnemy', {
                    width    : 1,
                    height   : 2,
                    template : 'greencube'
                }]
            }
        });

        var myLevel = {
            spawn : {
                main : [15, 24]
            },
            camera : {
                attached : ['character', 0, 6, 60]
            },
            light : {
                myLight : {
                     type : GLGE.L_POINT,
                     rotY : 1.54,
                     color    : "#fff",
                     attached : ['character', 0,5,20]
                }
             },
            entities : [
                {template:'brickscube', top:0, left:0, width:30, height:3},
                {template:'brickscube', top:0, left:39, width:30, height:3},
                gma.platformEnemy({bottom:0, left:45, width:3, height:6}),
                gma.patrolEnemy({bottom:0, left:6, width:3, height:6, limitLeft: 3, limitRight:12}),
                {type:'jumpingJack', bottom:0, left:21},
                {type:'jumpingJack', bottom:3, left:24},
                {type:'jumpingJack', bottom:6, left:27}
            ]
        };
        manager.storeLevels(myLevel);

        gma.keyHandler.register(37, manager.character.move.curry(gma.constants.LEFT));
        gma.keyHandler.register(39, manager.character.move.curry(gma.constants.RIGHT));
        gma.keyHandler.register(32, manager.character.jump);

        manager.init();
    }
);

```


**定制摄像机**

Gamma默认的摄像机总是跟随这角色的移动离角色面前50个距离单位和z轴的50个距离单位。你可以改变某个level中的摄像机的属性：

```js

var myLevel = {
     camera : {
         locZ : 60,
          //跟随指定的角色在指定的位置 x,y[,z]
         attached : ['character',0, 6]
     }
 };

```


**要有灯光**

在游戏中在指定的level中添加灯光：

```js
var myLevel = {
    light : {
        myLight : {
            type : GLGE.L_POINT,
            rotY : 1.54,
            color    : "#fff",
            attached : ['character', 0,5,20]
        }
    }
};
```

上面我们定了一个白色(#fff)的点光源(point light)，它始终在角色的前面5个单位，上面20个单位。我们把这个点光源旋转了180度(1.54 弧度radians)以指向场景.

用方块作为主角似乎太丑了，怎么着也得整个猩猩模型来着，GammaJS支持Collada模型定义，[Collada](https://collada.org/)是开放的标准xml模型定义格式。大多数的3D模型应用支持导出成这样的格式(.dae)文件。

你可以下载猩猩模型：[https://github.com/Royce/GammaJS/raw/master/media/collada/gorilla/gorilla.dae](https://github.com/Royce/GammaJS/raw/master/media/collada/gorilla/gorilla.dae),
以及对应的贴图文件：[https://github.com/Royce/GammaJS/raw/master/media/collada/gorilla/skin.jpg](https://github.com/Royce/GammaJS/raw/master/media/collada/gorilla/skin.jpg)

假定下载的文件放在和html文件同一目录下，现在可以把我们的大猩猩放在templates里了：

```js
manager.addCustomDefinitions({
    templates : {
        gorilla : ['colladaTemplate',
            {
                collada : {
                    document : 'gorilla.dae'
                }
            }
        ]
    }
})
```

不过我们要调整下，大猩猩的位置不对，中心不对，因此我们把它转180度，移动0.5个unit,缩放0.7倍。

```js
manager.addCustomDefinitions({
    templates : {
        gorilla : ['colladaTemplate',
            {
                collada : {
                    document : 'gorilla.dae'
                },
                yRot : 1.57,
                yOffset : -0.5,
                yScale : 0.7
            }
        ]
    }
})
```

ok，将大猩猩应用到角色：

```js
manager.character = gma.character({
    left     : 0,
    bottom   : 0,
    width    : 3,
    height   : 6,
    depth    : 3,
    template : 'gorilla'
});
```

好了，如今，再看看我们的game.js：

```js
require([
    'gma/base',
    'gma/manager',
    'gma/entities/character',
    'gma/events',
    'gma/entities/enemy'
],
    function(gma) {
        var manager = gma.manager({
            width : 600,
            height : 500
        });
        manager.character = gma.character({
            left     : 0,
            bottom   : 0,
            width    : 3,
            height   : 6,
            depth    : 3,
            template : 'gorilla'
        });
        manager.addCustomDefinitions({
            templates : {
                greencube : ['meshTemplate', {
                    mesh : gma.unitCubeInfo.mesh,
                    material : {color : "#090"}
                }],
                brickscube : ['meshTemplate', {
                    mesh : gma.unitCubeInfo.mesh,
                    texture : {
                        src:'bricks.jpg',
                        repeatX:0.5,
                        repeatY:0.5
                    }
                }],
                gorilla : ['colladaTemplate',
                    {
                        collada : {
                            document : 'gorilla.dae'
                        },
                        yRot : 1.57,
                        yOffset : -0.5,
                        yScale : 0.7
                    }
                ]
            },

            types : {
                jumpingJack: ['jumpingEnemy', {
                    width    : 1,
                    height   : 2,
                    template : 'greencube'
                }]
            }
        });

        var myLevel = {
            spawn : {
                main : [15, 24]
            },
            camera : {
                attached : ['character', 0, 6, 60]
            },
            light : {
                myLight : {
                     type : GLGE.L_POINT,
                     rotY : 1.54,
                     color    : "#fff",
                     attached : ['character', 0,5,20]
                }
             },
            entities : [
                {template:'brickscube', top:0, left:0, width:30, height:3},
                {template:'brickscube', top:0, left:39, width:30, height:3},
                gma.platformEnemy({bottom:0, left:45, width:3, height:6}),
                gma.patrolEnemy({bottom:0, left:6, width:3, height:6, limitLeft: 3, limitRight:12}),
                {type:'jumpingJack', bottom:0, left:21},
                {type:'jumpingJack', bottom:3, left:24},
                {type:'jumpingJack', bottom:6, left:27}
            ]
        };
        manager.storeLevels(myLevel);

        gma.keyHandler.register(37, manager.character.move.curry(gma.constants.LEFT));
        gma.keyHandler.register(39, manager.character.move.curry(gma.constants.RIGHT));
        gma.keyHandler.register(32, manager.character.jump);

        manager.init();
    }
);
```


一个游戏肯定应该是有多个level的，如何定义多个level呢？很简单：


```js
var myLevel = {
    //specification
};
var anotherLevel = {
    //specification
};
```


然后在初始化函数中：


```js
manager.storeLevels(myLevel);
manager.storeLevels(anotherLevel);
```

或者这样：

```js
manager.storeLevels([myLevel, anotherLevel]);
```


当mananger初始化的时候，首先是第一个level会被载入。然后我们只需要从一个level进入另一个level，这被称为门（door），下面演示如何创建一个门：


```js
entities : [
    gma.door({
        bottom:0, left:5, width:3, height:3,
        level:1
    })
]
```


注意：level 的索引是从0开始的。所以上面的level＝1是进入的第二个level（anotherLevel），现在我们来正式创建anotherLevel，它有一个门返回到第一个level：


```js
var otherLevel = {
    spawn : {
        main : [0, 0]
    },
    camera : {
        attached : ['character', 0, 6, 60]
    },
    light : {
        myLight : {
             type : GLGE.L_POINT,
             rotY : 1.54,
             color    : "#fff",
             attached : ['character', 0,5,20]
        }
     },
    entities : [
        gma.door({bottom:0, left:25, width:0.5, height:9, level:0}),
        {template:'brickscube', top:0, left:0, width:30, height:3}
    ]
};
```


好了，到现在为止，在我们的game.js中有两个level了：


```js
require([
    'gma/base',
    'gma/manager',
    'gma/entities/character',
    'gma/events',
    'gma/entities/enemy',
    'gma/entities/door'
],
    function(gma) {
        var manager = gma.manager({
            width : 600,
            height : 500
        });
        manager.character = gma.character({
            left     : 0,
            bottom   : 0,
            width    : 3,
            height   : 6,
            depth    : 3,
            template : 'gorilla'
        });
        manager.addCustomDefinitions({
            templates : {
                greencube : ['meshTemplate', {
                    mesh : gma.unitCubeInfo.mesh,
                    material : {color : "#090"}
                }],
                gorilla : ['colladaTemplate',
                {
                    collada : {
                        document : 'gorilla.dae'
                    },
                    yRot : 1.57,
                    yOffset : -0.5,
                    yScale:0.7
                }],
                brickscube : ['meshTemplate', {
                    mesh : gma.unitCubeInfo.mesh,
                    texture : {
                        src:'bricks.jpg',
                        repeatX:0.5,
                        repeatY:0.5
                    }
                }]
            },

            types : {
                jumpingJack: ['jumpingEnemy', {
                    width    : 1,
                    height   : 2,
                    template : 'greencube'
                }]
            }
        });

        var myLevel = {
            spawn : {
                main : [15, 24]
            },
            camera : {
                attached : ['character', 0, 6, 60]
            },
            light : {
                myLight : {
                     type : GLGE.L_POINT,
                     rotY : 1.54,
                     color    : "#fff",
                     attached : ['character', 0,5,20]
                }
             },
            entities : [
                gma.door({bottom:0, left:55, width:0.5, height:9, level:1}),
                {template:'brickscube', top:0, left:0, width:30, height:3},
                {template:'brickscube', top:0, left:39, width:30, height:3},
                gma.platformEnemy({bottom:0, left:45, width:3, height:6}),
                gma.patrolEnemy({bottom:0, left:6, width:3, height:6, limitLeft: 3, limitRight:12}),
                {type:'jumpingJack', bottom:0, left:21},
                {type:'jumpingJack', bottom:3, left:24},
                {type:'jumpingJack', bottom:6, left:27}
            ]
        };

        var otherLevel = {
            spawn : {
                main : [0, 0]
            },
            camera : {
                attached : ['character', 0, 6, 60]
            },
            light : {
                myLight : {
                     type : GLGE.L_POINT,
                     rotY : 1.54,
                     color    : "#fff",
                     attached : ['character', 0,5,20]
                }
             },
            entities : [
                gma.door({bottom:0, left:25, width:0.5, height:9, level:0}),
                {template:'brickscube', top:0, left:0, width:30, height:3}
            ]
        };

        manager.storeLevels(myLevel);
        manager.storeLevels(otherLevel);

        gma.keyHandler.register(37, manager.character.move.curry(gma.constants.LEFT));
        gma.keyHandler.register(39, manager.character.move.curry(gma.constants.RIGHT));
        gma.keyHandler.register(32, manager.character.jump);
        manager.init();
    }
);
```


我们现在还需要什么？还少一个显示的HUP（Heads Up Display），让我们在右下角显示FPS：


```js
manager.hud.setup({
    bottom_right: {
        fps : manager.getFPS
    }
});
```


HUD的显示类型可由CSS控制:


```css
/* Setup the bars */

#top_hud, #bottom_hud {
    height:2em;
    position:absolute;
    left:0em;
    width:100%;
    background-color: black;
    color: white;
    background-color: rgba(0, 0, 0, 0.7);
}

#top_hud {
    top:0em;
}
#bottom_hud {
    bottom:0em;
}

/* Setup left and right part of each bar */

#bottom_hud dl, #top_hud dl {
    margin: 0.3em;
}

#bottom_hud dl.left, #top_hud dl.left {
    float: left;
}
#bottom_hud dl.right, #top_hud dl.right {
    float: right;
}

/* Setup labels for each item */

#bottom_hud dt, #top_hud dt,
#bottom_hud dd, #top_hud dd {
    display: inline-block;
    line-height: 1.4em;
    margin: 0;
}

#bottom_hud dt, #top_hud dt {
    padding-right: 0.5em;
}

#bottom_hud dd, #top_hud dd {
    text-align: right;
}
dl.left dd {
    padding-right: 1em;
}
dl.right dt {
    padding-left: 1em;
}
```


将这个CSS保存为game.css文件放在game.js所在的目录下，取消html中的注释：


```html
<!--
    Include any style sheets here
    <link rel="stylesheet" type="text/css" href="gamma.css" media="all"/>
-->
```

ok，现在是这个没啥意思的游戏最后一个，当前，如果角色如果从台子上掉了下去，那么角色就会处于永远的掉之中，不会结束。怎么停止这个状态？很简单，在台子下面放一个“死亡台子”（deathPlatform），只要角色掉在这个台子上就会被杀掉：

```js
// Create a deathplatform type
types : {
    lava : ['deathPlatform', {template : 'redcube', depth:50}]
}
// Add this lava / death platform to the list of entities
entities : [
    {type:'lava', top:-10, left:-50, width:1000, height:50},
]
```


当角色死掉后，怎么重生呢？我们将重生的过程绑定到按键“r”上，当按下“r”就让角色重生：


```js
gma.keyHandler.register(82, function(e) {
    manager.respawn("main");
});
```

现在，我们终于完成了我们的游戏：

```js
require([
    'gma/base',
    'gma/manager',
    'gma/entities/character',
    'gma/events',
    'gma/entities/enemy',
    'gma/entities/door'
],
    function(gma) {
        var manager = gma.manager({
            width : 600,
            height : 500
        });
        manager.character = gma.character({
            left     : 0,
            bottom   : 0,
            width    : 3,
            height   : 6,
            depth    : 3,
            template : 'gorilla'
        });
        manager.addCustomDefinitions({
            templates : {
                greencube : ['meshTemplate', {
                    mesh : gma.unitCubeInfo.mesh,
                    material : {color : "#090"}
                }],
                gorilla : ['colladaTemplate',
                {
                    collada : {
                        document : 'gorilla.dae'
                    },
                    yRot : 1.57,
                    yOffset : -0.5,
                    yScale:0.7
                }],
                brickscube : ['meshTemplate', {
                    mesh : gma.unitCubeInfo.mesh,
                    texture : {
                        src:'bricks.jpg',
                        repeatX:0.5,
                        repeatY:0.5
                    }
                }]
            },

            types : {
                jumpingJack: ['jumpingEnemy', {
                    width    : 1,
                    height   : 2,
                    template : 'greencube'
                }],
                lava : ['deathPlatform', {template : 'redcube', depth:50}]
            }

        });

        manager.hud.setup({
            bottom_right: {
                fps : manager.getFPS
            }
        });

        var myLevel = {
            spawn : {
                main : [15, 24]
            },
            camera : {
                attached : ['character', 0, 6, 60]
            },
            light : {
                myLight : {
                     type : GLGE.L_POINT,
                     rotY : 1.54,
                     color    : "#fff",
                     attached : ['character', 0,5,20]
                }
             },
            entities : [
                gma.door({bottom:0, left:55, width:0.5, height:9, level:1}),
                {template:'brickscube', top:0, left:0, width:30, height:3},
                {template:'brickscube', top:0, left:39, width:30, height:3},
                {type:'deathPlatform', top:-10, left:-50, width:1000, height:50, depth:50},
                gma.platformEnemy({bottom:0, left:45, width:3, height:6}),
                gma.patrolEnemy({bottom:0, left:6, width:3, height:6, limitLeft: 3, limitRight:12}),
                {type:'jumpingJack', bottom:0, left:21},
                {type:'jumpingJack', bottom:3, left:24},
                {type:'jumpingJack', bottom:6, left:27}
            ]
        };

        var otherLevel = {
            spawn : {
                main : [0, 0]
            },
            camera : {
                attached : ['character', 0, 6, 60]
            },
            light : {
                myLight : {
                     type : GLGE.L_POINT,
                     rotY : 1.54,
                     color    : "#fff",
                     attached : ['character', 0,5,20]
                }
             },
            entities : [
                gma.door({bottom:0, left:25, width:0.5, height:9, level:0}),
                {template:'brickscube', top:0, left:0, width:30, height:3},
                {type:'deathPlatform', top:-10, left:-50, width:1000, height:50, depth:50}
            ]
        };

        manager.storeLevels(myLevel);
        manager.storeLevels(otherLevel);

        gma.keyHandler.register(37, manager.character.move.curry(gma.constants.LEFT));
        gma.keyHandler.register(39, manager.character.move.curry(gma.constants.RIGHT));
        gma.keyHandler.register(32, manager.character.jump);
        gma.keyHandler.register(82, function(e) { manager.respawn("main"); });
        manager.init();
    }
);
```

更完整的例子在:[这里](https://github.com/Royce/GammaJS/tree/master/examples/fancy)

本教程翻译自： [这里](https://github.com/Royce/GammaJS/tree/master/docs/tutorials)

还有很多好玩的3D引擎，限于时间就不一一介绍了，下面就罗列下：

* [Minko Engine](https://minko.io/engine/):
  * Build cross-platform 3D apps for HTML5, iOS, Android, Windows, OS X and Linux using a single C/C++ code base.
  * [Source Code](https://github.com/aerys/minko/)
* [Goo Engine](http://goocreate.com/)
  *  [Source Code](https://code.gooengine.com/)
* [CooperLicht](http://www.ambiera.com/copperlicht/): Open Source WebGL 3D engine with editor
* [Blend4Web](https://www.blend4web.com/zh/) 做演示不错
* [Babylon.js](http://www.babylonjs.com/): JavaScript 3D games engine
* [Voxel.JS](http://voxeljs.com/):
  * a collection of projects that make it easier than ever to create 3D voxel games like Minecraft.
  * [Source coe on Github](https://github.com/maxogden/voxel-engine)
* [Enchant.js](https://github.com/wise9/enchant.js): A simple JavaScript framework for creating games and apps
* [KickJS](http://www.kickjs.org/):  WebGL based game engine
  * [Source code on GitHub](https://github.com/mortennobel/KickJS/)
* [Famo.us](http://famo.us/): HTML5 3D development Framework
  * [University](http://famo.us/university/home/)
  * [Source code on GitHub](https://github.com/Famous/famous)
* [PlayCanvas.js](https://playcanvas.com/)
* [Three.js](http://threejs.org/)
* [Turbulenz](http://biz.turbulenz.com/developers): Open source HTML5 2D/3D game engine since 2009
* [Google O3D](code.google.com/p/o3d/)
* [OSG.JS](http://osgjs.org/): a WebGL framework based on OpenSceneGraph concepts
  * [Source code on GitHub](http://github.com/cedricpinson/osgjs)
* [X3DOM](https://github.com/x3dom/x3dom): integrating and manipulating (X)3D scenes as HTML5 DOM elements
* [SceneJS - WebGL Scene Graph Library](http://www.scenejs.org/)
* [C3DL](http://www.c3dl.org/): a Canvas 3D JavaScript library
* [PhiloJS](http://www.senchalabs.org/philogl/): a WebGL Framework for Data Visualization
* [GLGE](http://www.glge.org/)
* [JigLibJS 物理引擎](http://www.jiglibjs.org/)－ 强烈推荐去看看


